# rubocop:disable Style/Documentation, Metrics/*
# frozen_string_literal: true

require_relative 'mail_to_pdf'

require 'mapi/msg'
require 'rfc_2047'

Mapi::Log.level = Logger::Severity::INFO

module Libis
  module Format
    module Tool
      class MsgToPdf < MailToPdf
        protected

        def open_email(source)
          # Open the message
          Mapi::Msg.open(source)
        end

        def close_email(msg)
          msg.close
          true
        end

        def get_body_html(msg)
          # Get the body of the message in HTML
          body = msg.properties.body_html

          # Embed plain body in HTML as a fallback
          body ||= HTML_WRAPPER_TEMPLATE % msg.properties.body

          # Worst case, just create empty body
          body ||= HTML_WRAPPER_TEMPLATE % ''

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

          body
        end

        def get_subject(msg)
          find_hdr(msg.headers, 'Subject') || 'No Subject'
        end

        def get_headers(msg)
          headers = {}
          html = ''

          %w[From To Cc Subject Date].each do |key|
            value = find_hdr(msg.headers, key)
            next unless value

            if key.casecmp('Date').zero?
              begin
                value = DateTime.parse(value).to_time.localtime
                headers[key.downcase.to_sym] = value.iso8601
                html += hdr_html(key, value.rfc2822)
              rescue StandardError => e
                logger.warn "Failed to parse date header '#{value}': #{e.message}"
              end
            else
              headers[key.downcase.to_sym] = value
              html += hdr_html(key, value)
            end
          end

          [headers, html]
        end

        def get_inline_attachment_data(attachments, cid)
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

        def get_file_attachments(attachments, used_files)
          attachments.select do |attachment|
            !attachment.properties.attachment_hidden &&
              attachment.filename &&
              !attachment.filename.empty? &&
              !used_files.include?(attachment.filename)
          end
        end

        def get_mail_attachments(attachments)
          attachments.select do |attachment|
            !attachment.properties.attachment_hidden &&
              attachment.instance_variable_get(:@embedded_msg)
          end
        end

        def get_attachment_info(attachment)
          if (sub_msg = attachment.instance_variable_get(:@embedded_msg))

            {
              embedded_msg: sub_msg,
              filename: attachment.properties[:display_name] || sub_msg.subject || ''
            }

          elsif attachment.filename
            io = StringIO.new
            attachment.save(io)
            io.rewind

            {
              data: io.string,
              filename: attachment.filename
            }

          else
            {
              filename: attachment.properties[:display_name] || 'unknown'
            }
          end
        end

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
      end
    end
  end
end
# rubocop:enable Style/Documentation, Metrics/*
