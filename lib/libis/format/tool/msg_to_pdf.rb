# frozen_string_literal: true

require 'mapi/msg'
require 'rfc_2047'
require 'cgi'
require 'pdfkit'

require 'fileutils'

require 'libis/format/config'

module Libis
  module Format
    module Tool
      class MsgToPdf
        include ::Libis::Tools::Logger

        HEADER_STYLE = '<style>.header-table {margin: 0 0 20 0;padding: 0;font-family: Arial, Helvetica, sans-serif;}.header-name {padding-right: 5px;color: #9E9E9E;text-align: right;vertical-align: top;font-size: 12px;}.header-value {font-size: 12px;}#header_fields {#background: white;#margin: 0;#border: 1px solid #DDD;#border-radius: 3px;#padding: 8px;#width: 100%%;#box-sizing: border-box;#}</style><script type="text/javascript">function timer() {try {parent.postMessage(Math.max(document.body.offsetHeight, document.body.scrollHeight), \'*\');} catch (r) {}setTimeout(timer, 10);};timer();</script>' # rubocop:disable Layout/LineLength
        HEADER_TABLE_TEMPLATE = '<div class="header-table"><table id="header_fields"><tbody>%s</tbody></table></div>'
        HEADER_FIELD_TEMPLATE = '<tr><td class="header-name">%s</td><td class="header-value">%s</td></tr>'
        HTML_WRAPPER_TEMPLATE = '<!DOCTYPE html><html><head><style>body {font-size: 0.5cm;}</style><title>title</title></head><body>%s</body></html>' # rubocop:disable Layout/LineLength

        IMG_CID_PLAIN_REGEX = /\[cid:(.*?)\]/m
        IMG_CID_HTML_REGEX = /cid:([^"]*)/m

        def self.installed?
          File.exist?(Libis::Format::Config[:wkhtmltopdf])
        end

        def self.run(source, target, **options)
          new.run source, target, **options
        end

        def run(source, target, **options)
          # Preliminary checks
          # ------------------

          @warnings = []

          # Check if source file exists
          raise "File #{source} does not exist" unless File.exist?(source)

          # Retrieving the message
          # ----------------------

          # Open the message
          msg = Mapi::Msg.open(source)

          target_format = options.delete(:to_html) ? :HTML : :PDF
          result = msg_to_pdf(msg, target, target_format, options)
          msg.close
          result
        end

        def msg_to_pdf(msg, target, target_format, pdf_options, reraise: false)
          # Make sure the target directory exists
          outdir = File.dirname(target)
          FileUtils.mkdir_p(outdir)

          # Get the body of the message in HTML
          body = msg.properties.body_html

          # Embed plain body in HTML as a fallback
          body ||= HTML_WRAPPER_TEMPLATE % msg.properties.body

          # Check and fix the character encoding
          begin
            # Try to encode into UTF-8
            body.encode!('UTF-8', universal_newline: true)
          rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
            begin
              # If it fails, the text may be in Windows' Latin1 (ISO-8859-1)
              body.force_encoding('ISO-8859-1').encode!('UTF-8', universal_newline: true)
            rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
              # If that fails too, log a warning and replace the invalid/unknown with a ? character.
              @warnings << "#{e.class}: #{e.message}"
              body.encode!('UTF-8', universal_newline: true, invalid: :replace, undef: :replace)
            end
          end

          # Process headers
          # ---------------
          headers = {}
          hdr_html = ''

          %w[From To Cc Subject Date].each do |key|
            value = find_hdr(msg.headers, key)
            if value
              headers[key.downcase.to_sym] = value
              hdr_html += hdr_html(key, value)
            end
          end

          # Add header section to the HTML body
          unless hdr_html.empty?
            # Insert header block styles
            if body =~ %r{</head>}
              # if head exists, append the style block
              body.gsub!(%r{</head>}, "#{HEADER_STYLE}</head>")
            elsif body =~ %r{<head/>}
              # empty head, replace with the style block
              body.gsub!(%r{<head/>}, "<head>#{HEADER_STYLE}</head>")
            else
              # otherwise insert a head section before the body tag
              body.gsub!(/<body/, "<head>#{HEADER_STYLE}</head><body")
            end
            # Add the headers html table as first element in the body section
            body.gsub!(/<body[^>]*>/) { |m| "#{m}#{HEADER_TABLE_TEMPLATE % hdr_html}" }
          end

          # Embed inline images
          # -------------------
          attachments = msg.attachments
          used_files = []

          # First process plaintext cid entries
          body.gsub!(IMG_CID_PLAIN_REGEX) do |_match|
            data = get_attachment_data(attachments, ::Regexp.last_match(1))
            return '<img src=""/>' unless data

            used_files << ::Regexp.last_match(1)
            "<img src=\"data:#{data[:mime_type]};base64,#{data[:base64]}\"/>"
          end

          # Then process HTML img tags with CID entries
          body.gsub!(IMG_CID_HTML_REGEX) do |_match|
            data = get_attachment_data(attachments, ::Regexp.last_match(1))
            return '' unless data

            used_files << ::Regexp.last_match(1)
            "data:#{data[:mime_type]};base64,#{data[:base64]}"
          end

          # Create PDF
          # ----------
          files = []

          if target_format == :PDF
            # PDF creation options
            pdf_options = {
              page_size: 'A4',
              margin_top: '10mm',
              margin_bottom: '10mm',
              margin_left: '10mm',
              margin_right: '10mm',
              # image_quality: 100,
              # viewport_size: '2480x3508',
              dpi: 300
            }.merge pdf_options

            subject = find_hdr(msg.headers, 'Subject')
            kit = PDFKit.new(body, title: (subject || 'message'), **pdf_options)
            pdf = kit.to_pdf
            File.open(target, 'wb') { |f| f.write(pdf) }
          else
            File.open(target, 'wb') { |f| f.write(body) }
          end
          files << target if File.exist?(target)

          # Save attachments
          # ----------------
          outdir = File.join(outdir, "#{File.basename(target)}.attachments")
          attached_files = []
          attachments.delete_if { |a| a.properties.attachment_hidden }.each do |a|
            if (sub_msg = a.instance_variable_get(:@embedded_msg))
              subject = a.properties[:display_name] || sub_msg.subject || "attachment_#{a.properties[:attach_num]}"
              subdir = File.join(outdir, subject.to_s)
              FileUtils.mkdir_p(subdir)
              result = msg_to_pdf(
                sub_msg, File.join(subdir, "message.#{target_format.to_s.downcase}"),
                target_format, pdf_options, reraise: true
              )
              files += result[:files]
              attached_files << subject
            elsif a.properties.attach_data && a.filename
              next if used_files.include?(a.filename)

              file = File.join(outdir, a.filename)
              FileUtils.mkdir_p(File.dirname(file))
              File.open(file, 'wb') { |f| a.save(f) }
              files << file
              attached_files << File.basename(file)
            else
              @warnings << "Attachment #{a.properties[:display_name]} cannot be saved"
            end
          end

          headers.merge!(attachments: attached_files)
          {
            command: { status: 0 },
            files:,
            headers:,
            warnings: @warnings
          }
        rescue Exception => e
          raise if reraise

          msg.close
          {
            command: { status: -1 },
            files: [],
            headers: {},
            errors: [
              {
                error: e.message,
                error_class: e.class.name,
                error_trace: e.backtrace
              }
            ],
            warnings: @warnings
          }
        end

        protected

        def eml_to_html; end

        private

        def find_hdr(list, key)
          keys = list.keys
          if (k = keys.find { |x| x.to_s =~ /^#{key}$/i })
            v = list[k]
            v = v.first if v.is_a? Array
            v = Rfc2047.decode(v).strip if v.is_a? String
            return v
          end
          nil
        end

        def hdr_html(key, value)
          return format(HEADER_FIELD_TEMPLATE, key, CGI.escapeHTML(value)) if key.is_a?(String) && value.is_a?(String) && !value.empty?

          ''
        end

        def get_attachment_data(attachments, cid)
          attachments.each do |attachment|
            next unless attachment.properties.attach_content_id == cid

            attachment.data.rewind
            return {
              mime_type: attachment.properties.attach_mime_tag,
              base64: Base64.encode64(attachment.data.read).gsub(/[\r\n]/, '')
            }
          end
          nil
        end
      end
    end
  end
end
