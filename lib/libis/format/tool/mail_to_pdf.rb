# rubocop:disable Style/Documentation, Metrics/*
# frozen_string_literal: true

require 'base64'
require 'cgi'
require 'pdfkit'
require 'time'
require 'fileutils'
require 'pathname'

module Libis
  module Format
    module Tool
      HEADER_STYLE = <<~HTML
        <style>
          .header-table {
            margin: 0 0 10px 0;
            padding: 0;
            font-family: Arial, Helvetica, sans-serif;
          }
          .header-table table {
            width: 100%;
          }
          .header-name {
            padding-right: 5px;
            color: #9E9E9E;
            text-align: right;
            vertical-align: top;
            font-size: 12px;
          }
          .header-value {
            font-size: 12px;
            width: 99%;
          }
          .header_fields {
            background: white;
            margin: 0;
            border: 1px solid #DDD;
            border-radius: 3px;
            padding: 8px;
            box-sizing: border-box;
          }
        </style>
      HTML

      HEADER_TABLE_TEMPLATE = <<~HTML
        <div class="header-table">
          <table class="header_fields">
            <tbody>
        %s
            </tbody>
          </table>
        </div>
      HTML

      HEADER_FIELD_TEMPLATE = <<~HTML
        <tr>
          <td class="header-name">%s</td>
          <td class="header-value">%s</td>
        </tr>
      HTML

      HTML_WRAPPER_TEMPLATE = <<~HTML
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                font-size: 12px;
                }
            </style>
            <title>title</title>
          </head>
          <body>
            <pre>
        %s
            </pre>
          </body>
        </html>
      HTML

      HTML_BODY_TEMPLATE = <<~HTML
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                font-size: 12px;
              }
            </style>
            <title>title</title>
          </head>
          <body>
            %s
          </body>
        </html>
      HTML

      ATTACHMENT_STYLE = <<~HTML
        <style>
          .attachment-list {
            border: 1px solid #DDD;
            margin: 0 0 10px 0;
            padding: 0;
            font-family: Arial, Helvetica, sans-serif;
          }
          .attachment-list ul {
            list-style: disclosure-closed;
          }
          .attachment-list li {
            font-size: 12px;
            padding-left: 1em;
          }
        </style>
      HTML

      ATTACHMENT_LIST_TEMPLATE = <<~HTML
        <div class="attachment-list">
          <ul>
        %s
          </ul>
        </div>
      HTML

      HTML_DOCTYPE_TEMPLATE = '<!DOCTYPE html>%s'
      ATTACHMENT_ITEM_TEMPLATE = '<li>%s</li>'

      IMG_CID_PLAIN_REGEX = /\[cid:(.*?)\]/im
      IMG_CID_HTML_REGEX = /cid:([^"]*)/im

      class MailToPdf

        def self.run(source, target, **options)
          new.run source, target, **options
        end

        def run(source, target, **options)
          # Preliminary checks
          @warnings = []

          # PDF creation options
          @pdf_options = {
            page_size: 'A4',
            margin_top: '10mm',
            margin_bottom: '10mm',
            margin_left: '10mm',
            margin_right: '10mm',
            # image_quality: 100,
            # viewport_size: '2480x3508',
            dpi: 300
          }.merge options

          # Check if source file exists
          raise "File #{source} does not exist" unless File.exist?(source)

          # Open the email
          email = open_email(source)

          # Convert the email message to PDF
          result = email_to_pdf(email, target, root_msg: true, output_format: options.fetch(:output_format, :pdf))

          # Close email message
          close_email(email)

          result
        end

        protected

        def email_to_pdf(msg, target, root_msg: false, output_format: :pdf)
          # Make sure the target directory exists
          outdir = File.dirname(target)
          FileUtils.mkdir_p(outdir)

          # Process the message body
          # ------------------------
          body = get_body(msg)

          # Process headers
          # ---------------
          headers, headers_html = get_headers(msg)

          # Add header section to the HTML body
          body = add_headers_to_body(body, headers_html)

          # Embed inline images
          # -------------------
          attachments = msg.attachments
          used_files = embed_inline_attachments(body, attachments)

          # Save other attachments
          # ----------------------
          attachments_dir = "#{target}.attachments"

          files = save_attachments(attachments, attachments_dir, used_files, output_format: output_format)

          # Add attachment section to the HTML body
          body = add_attachments_to_body(body, files, attachments_dir)

          if output_format == :html
            # Create HTML file
            File.open(target, 'wb') { |f| f.write(body) }
          else
            # Create PDF
            write_target_file(body, get_subject(msg), target)
          end

          files = [target] + files if File.exist?(target)

          if root_msg
            p = Pathname(File.dirname(files.first))
            files.drop(1).each do |f|
              (headers[:attachments] ||= []) << Pathname.new(f).relative_path_from(p).to_s
            end
          end

          {
            command: { status: 0 },
            files: files,
            headers: headers,
            warnings: @warnings
          }
        rescue StandardError => e
          raise unless root_msg

          close_email(msg) if msg
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

        def get_body(msg)
          body = get_body_html(msg)

          body = HTML_BODY_TEMPLATE % body unless /<body[^>]*>/i.match?(body)
          body = HTML_DOCTYPE_TEMPLATE % body unless /<!DOCTYPE html/i.match?(body)
          body.sub!(%r{<title>title</title>}, "<title>#{get_subject(msg)}</title>")

          body
        end

        def add_headers_to_body(body, headers_html)
          encoding = body.encoding
          return body if headers_html.empty?

          b = body.downcase

          # Insert header block styles
          if b.include?('</head>')
            # if head exists, append the style block
            body.gsub!(%r{</head>}i, "#{HEADER_STYLE}</head>")
          elsif b.include?('<head/>')
            # empty head, replace with the style block
            body.gsub!(%r{<head/>}i, "<head>#{HEADER_STYLE}</head>")
          else
            # otherwise insert a head section before the body tag
            body.gsub!(/<body/i, "<head>#{HEADER_STYLE}</head><body")
          end
          # Add the headers html table as first element in the body section
          body.gsub!(/<body[^>]*>/i) { |m| "#{m}#{HEADER_TABLE_TEMPLATE % headers_html.encode(encoding)}" }
          body
        end

        def hdr_html(key, value)
          if key.is_a?(String) && value.is_a?(String) && !value.empty?
            return format(HEADER_FIELD_TEMPLATE, key,
                          CGI.escapeHTML(value))
          end

          ''
        end

        def embed_inline_attachments(body, attachments)
          used_files = []

          # First process plaintext cid entries
          body.gsub!(IMG_CID_PLAIN_REGEX) do |_match|
            data = get_inline_attachment_data(attachments, ::Regexp.last_match(1))
            if data
              used_files << ::Regexp.last_match(1)
              "<img src=\"data:#{data[:mime_type]};base64,#{data[:base64]}\"/>"
            else
              '<img src=""/>'
            end
          end

          # Then process HTML img tags with CID entries
          body.gsub!(IMG_CID_HTML_REGEX) do |_match|
            data = get_inline_attachment_data(attachments, ::Regexp.last_match(1))
            if data
              used_files << ::Regexp.last_match(1)
              "data:#{data[:mime_type]};base64,#{data[:base64]}"
            else
              ''
            end
          end

          used_files
        end

        def save_attachments(attachments, outdir, used_files, output_format: :pdf)
          files = []

          digits = ((attachments.count + 1) / 10) + 1
          i = 1

          get_attachments(attachments, used_files).each do |attachment|
            prefix = "#{format('%0*d', digits, i)}-"

            info = get_attachment_info(attachment)

            if info[:embedded_msg]
              sub_msg = info[:embedded_msg]
              file = File.join(outdir, "#{prefix}#{info[:filename].tr('/', '_')}.msg.#{output_format}")

              result = email_to_pdf(sub_msg, file, root_msg: false, output_format: output_format)

              if (e = result[:error])
                raise e
              end

              files += result[:files]
            elsif info[:data]
              file = File.join(outdir, "#{prefix}#{info[:filename].tr('/', '_')}")
              FileUtils.mkdir_p(File.dirname(file))
              File.open(file, 'wb') { |f| f.write(info[:data]) }
              files << file
            else
              @warnings << "Attachment #{info[:filename]} cannot be extracted"
              next
            end

            i += 1
          end
          files
        end

        def add_attachments_to_body(body, files, attachments_dir)
          return body if files.empty?

          b = body.downcase

          # Insert attachment block styles
          if b.include?('</head>')
            # if head exists, append the style block
            body.gsub!(%r{</head>}i, "#{ATTACHMENT_STYLE}</head>")
          elsif b.include?('<head/>')
            # empty head, replace with the style block
            body.gsub!(%r{<head/>}i, "<head>#{ATTACHMENT_STYLE}</head>")
          else
            # otherwise insert a head section before the body tag
            body.gsub!(/<body/i, "<head>#{ATTACHMENT_STYLE}</head><body")
          end

          # Filter files to only include those that are in the attachments directory
          # and map them to relative paths from the attachments directory
          items = files.filter_map do |f|
            Pathname.new(f).relative_path_from(Pathname.new(attachments_dir)).to_s if File.dirname(f) == attachments_dir
          end

          # Create the attachment item HTML
          items = items.map do |f|
            format(ATTACHMENT_ITEM_TEMPLATE, f, File.basename(f))
          end.join("\n")

          # Create the attachment list HTML
          attachments_html = ATTACHMENT_LIST_TEMPLATE % items

          # make sure the attachments_html is encoded in the same encoding as the body
          attachments_html = attachments_html.encode(body.encoding)

          # Add the attachments html list after the headers
          # if there are no headers, then add it at the beginning of the body section
          body.sub!(%r{<div class="header-table">.*?</div>}im) { |m| "#{m}#{attachments_html}" } ||
            body.gsub!(/<body[^>]*>/i) { |m| "#{m}#{attachments_html}" }

          body
        end

        def get_attachments(attachments, used_files)
          get_file_attachments(attachments, used_files) + get_mail_attachments(attachments)
        end

        def write_target_file(body, title, target)
          kit = PDFKit.new(body, title: title || 'message', **@pdf_options)
          pdf = kit.to_pdf
          File.open(target, 'wb') { |f| f.write(pdf) }
        end

        # ---------------------------------------
        # Methods to be implemented by subclasses
        # ---------------------------------------
        def open_email(_source)
          raise NotImplementedError, 'Subclasses must implement the open_email method'
        end

        def close_email(_email)
          raise NotImplementedError, 'Subclasses must implement the close_email method'
        end

        def get_body_html(_msg)
          raise NotImplementedError, 'Subclasses must implement the get_body_html method'
        end

        def get_subject(_msg)
          raise NotImplementedError, 'Subclasses must implement the get_subject method'
        end

        def get_headers(_msg)
          raise NotImplementedError, 'Subclasses must implement the get_headers method'
        end

        def get_inline_attachment_data(_attachments, _cid)
          raise NotImplementedError, 'Subclasses must implement the get_inline_attachment_data method'
        end

        def get_file_attachments(_attachments, _used_files)
          raise NotImplementedError, 'Subclasses must implement the get_file_attachments method'
        end

        def get_mail_attachments(_attachments)
          raise NotImplementedError, 'Subclasses must implement the get_mail_attachments method'
        end

        def get_attachment_info(_attachment)
          raise NotImplementedError, 'Subclasses must implement the get_attachment_info method'
        end
      end
    end
  end
end
# rubocop:enable Style/Documentation, Metrics/*
