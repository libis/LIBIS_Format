require_relative 'identification_tool'

module Libis
  module Format
    module Tool

      class ExtensionIdentification < Libis::Format::Tool::IdentificationTool

        def run_list(filelist)

          output = runner(nil, filelist)

          process_output(output)

        end

        def run_dir(dir, recursive = true)

          filelist = find_files(dir, recursive)

          output = runner(nil, filelist)

          process_output(output)

        end

        def run(file)

          output = runner(file)

          process_output(output)

        end

        protected

        def runner(*args)

          args.map do |file|
            info = ::Libis::Format::TypeDatabase.ext_infos(File.extname(file)).first
            if info
              {
                  filepath: file,
                  mimetype: (info[:MIME].first rescue nil),
                  puid: (info[:PUID].first rescue nil),
                  matchtype: 'extension',
                  source: :type_database
              }
            end
          end.cleanup

        end

      end

    end
  end
end