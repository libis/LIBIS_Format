require_relative 'identification_tool'

module Libis
  module Format
    module Tool

      class ExtensionIdentification < Libis::Format::Tool::IdentificationTool

        def run_list(filelist, _options = {})

          output = runner(nil, filelist)

          process_output(output)

        end

        def run_dir(dir, recursive = true, _options = {})

          filelist = find_files(dir, recursive)

          output = runner(nil, filelist)

          process_output(output)

        end

        def run(file, _options)

          output = runner(file)

          process_output(output)

        end

        protected

        def runner(*args)

          args.map do |file|
            info = ::Libis::Format::Library.get_info_by(:extension, File.extname(file))
            if info
              {
                  filepath: file,
                  mimetype: (info[:mimetypes].first rescue nil),
                  puid: (info[:puids].first rescue nil),
                  matchtype: 'extension',
                  tool: :format_library
              }
            end
          end.cleanup

        end

      end

    end
  end
end