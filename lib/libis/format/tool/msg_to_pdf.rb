# encoding: utf-8

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

        HEADER_STYLE = '<style>.header-table {margin: 0 0 20 0;padding: 0;font-family: Arial, Helvetica, sans-serif;}.header-name {padding-right: 5px;color: #9E9E9E;text-align: right;vertical-align: top;font-size: 12px;}.header-value {font-size: 12px;}#header_fields {background: white;margin: 0;border: 1px solid #DDD;border-radius: 3px;padding: 8px;width: 100%%;box-sizing: border-box;}</style><script type="text/javascript">function timer() {try {parent.postMessage(Math.max(document.body.offsetHeight, document.body.scrollHeight), \'*\');} catch (r) {}setTimeout(timer, 10);};timer();</script>'
        HEADER_TABLE_TEMPLATE = '<div class="header-table"><table id="header_fields"><tbody>%s</tbody></table></div>'
        HEADER_FIELD_TEMPLATE = '<tr><td class="header-name">%s</td><td class="header-value">%s</td></tr>'
        HTML_WRAPPER_TEMPLATE = '<!DOCTYPE html><html><head><style>body {font-size: 0.5cm;}</style><title>title</title></head><body>%s</body></html>'

        IMG_CID_PLAIN_REGEX = %r/\[cid:(.*?)\]/m
        IMG_CID_HTML_REGEX = %r/cid:([^"]*)/m

        def self.installed?
          File.exist?(Libis::Format::Config[:wkhtmltopdf])
        end

        def self.run(source, target, options = {})
          new.run source, target, options
        end

        def run(source, target, options = {})
          # Preliminary checks
          # ------------------

          # Check if source file exists
          raise "File #{source} does not exist" unless File.exist?(source)

          # Make sure the target directory exists
          outdir = File.dirname(target)
          FileUtils.mkdir_p(outdir)

          # Retrieving the message
          # ----------------------

          # Open the message
          msg = Mapi::Msg.open(source)

          target_format = options.delete(:to_html) ? :PDF : :HTML
          msg_to_pdf(msg, target, target_format, options)
        end

        def msg_to_pdf(msg, target, target_format, pdf_options)
          outdir = File.dirname(target)

puts "Headers:"
puts '--------'
pp msg.headers

puts "Recipients:"
puts '-----------'
pp msg.recipients

puts "Body:"
puts '-----'
puts msg.properties.body
puts '-----'
puts msg.properties.body_rtf
puts '-----'
puts msg.properties.body_html

puts "Attachments:"
puts '------------'
msg.attachments.each {|a| p "#{a.filename} - #{a.properties.attach_content_id}"}

puts "Converting:"
puts '-----------'

          # Get the body of the message in HTML
          body = msg.properties.body_html
          body ||= begin
            # Embed plain body in HTML as a fallback
            HTML_WRAPPER_TEMPLATE % msg.properties.body
          end

          # Check and fix the character encoding
          begin
            # Try to encode into UTF-8
            body.encode!('UTF-8', universal_newline: true)
          rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
            # If it fails, the text may be in Windows' Latin1 (ISO-8859-1)
            # Note that if there still are invalid or undefined characters, they will be replaced with the ? character
            body.force_encoding('ISO-8859-1').encode!('UTF-8', universal_newline: true, invalid: :replace, undef: :replace)
          end

          # Process headers
          # ---------------
          headers = {}
          hdr_html = ''

          %w"From To Cc Subject Date".each do |key|
            value = find_hdr(msg.headers, key)
            if value
              headers[key.downcase.to_sym] = value
              hdr_html += hdr_html(key, value)
            end
          end

          # Add header section to the HTML body
          unless hdr_html.empty?
            # Insert header block styles
            if body =~ /<\/head>/
              # if head exists, append the style block
              body.gsub!(/<\/head>/, HEADER_STYLE + '</head>')
            else
              # otherwise insert a head section before the body tag
              body.gsub!(/<body/, '<head>' + HEADER_STYLE + '</head><body')
            end
            # Add the headers html table as first element in the body section
            body.gsub!(/<body[^>]*>/) {|m| "#{m}#{HEADER_TABLE_TEMPLATE % headers}"}
          end

          # Embed inline images
          # -------------------
          attachments = msg.attachments

          # First process plaintext cid entries
          body.gsub!(IMG_CID_PLAIN_REGEX) do |match|
            data = getAttachmentData(attachments, $1)
            unless data
              return '<img src=""/>'
            end
            "<img src=\"data:#{data[:mime_type]};base64,#{data[:base64]}\"/>"
          end
          
          # Then process HTML img tags with CID entries
          body.gsub!(IMG_CID_HTML_REGEX) do |match|
            data = getAttachmentData(attachments, $1)
            unless data
              return ''
            end
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
              dpi: 300,
              # image_quality: 100,
              # viewport_size: '2480x3508',
            }.merge pdf_options

            kit = PDFKit.new(body, title: (find_hdr(msg.headers, 'Subject') || 'message'), **pdf_options)
            pdf = kit.to_pdf
            File.open(target, 'wb') {|f| f.write(pdf)}
          else
            File.open(target, 'wb') {|f| f.write(body)}
          end
          files << target if File.exist?(target)

          # Save attachments
          # ----------------
          attachments.delete_if {|a| a.properties.attachment_hidden}.each do |a|
            if a.filename
              file = File.join(outdir, a.filename)
              FileUtils.mkdir_p(File.dirname(file))
              File.open(file, 'wb') {|f| a.save(f)}
              files << file
  puts "Attachment file '#{file}' created"
            elsif sub_msg = a.instance_variable_get(:@embedded_msg)
              subject = a.properties[:display_name] || sub_msg.subject || "attachment_#{a.properties[:attach_num]}"
              subdir = File.join(outdir, "#{subject}.msg")
              FileUtils.mkdir_p(subdir)
              result = msg_to_pdf(sub_msg, File.join(subdir, "message.#{target_format.to_s.downcase}"), target_format, pdf_options)
              if e = result[:error]
                raise e
              end
              files += result[:files]
            else
            end
          end
          
          {
            command: {status: 0},
            files: files,
            headers: headers
          }
          
        rescue Exception => e
puts "ERROR: Exception #{e.class} raised: #{e.message}"
          return {
            error: e.message,
            command: nil,
            files: [],
            headers: {}
          }
        end

        protected

        def eml_to_html

        end

        private

        def find_hdr(list, key)
          keys = list.keys
          if k = keys.find {|x| x.to_s =~ /^#{key}$/i}
            v = list[k]
            v = v.first if v.is_a? Array
            v = Rfc2047.decode(v).strip if v.is_a? String
            return v
          end
          nil
        end

        def hdr_html(key, value)
          return HEADER_FIELD_TEMPLATE % [key, CGI::escapeHTML(value)] if key.is_a?(String) && value.is_a?(String) && !value.empty?
          ''
        end

        def getAttachmentData(attachments, cid)
          attachments.each do |attachment|
            if attachment.properties.attach_content_id == cid
              attachment.data.rewind
              return {
                mime_type: attachment.properties.attach_mime_tag,
                base64: Base64.encode64(attachment.data.read).gsub(/[\r\n]/, '')
              }
            end
          end
          return nil
        end

        def read_header(headers_file)
          headers = YAML.load_file(headers_file)
          headers.symbolize_keys
        end
      end
    end
  end
end
