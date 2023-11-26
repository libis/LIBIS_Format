# frozen_string_literal: true

require_relative 'identification_tool'

module Libis
  module Format
    module Tool
      class ExtensionIdentification < Libis::Format::Tool::IdentificationTool
        def run_list(filelist, **_options)
          output = runner(nil, filelist)

          process_output(output)
        end

        def run_dir(dir, recursive = true, **_options)
          filelist = find_files(dir, recursive)

          output = runner(nil, filelist)

          process_output(output)
        end

        def run(file, **_options)
          output = runner(file)

          process_output(output)
        end

        protected

        def runner(*args)
          args.map do |file|
            info = ::Libis::Format::TypeDatabase.ext_infos(File.extname(file)).first
            next unless info

            {
              filepath: file,
              mimetype: begin
                info[:MIME].first
              rescue StandardError
                nil
              end,
              puid: begin
                info[:PUID].first
              rescue StandardError
                nil
              end,
              matchtype: 'extension',
              tool: :type_database
            }
          end.cleanup
        end
      end
    end
  end
end
