require_relative 'identification_tool'

module Libis
  module Format
    module Tool

      class FileTool < Libis::Format::Tool::IdentificationTool

        def run_list(filelist, _options = {})

          create_list_file(filelist) do |list_file|

            output = runnerIdentificationTool(nil, '--files-from', list_file)

            process_output(output)

          end

        end

        def run_dir(dir, recursive = true, _options = {})

          filelist = find_files(dir, recursive)

          create_list_file(filelist) do |list_file|

            output = runner(nil, '--files-from', list_file)

            process_output(output)

          end

        end

        def run(file, _options = {})

          output = runner(file)

          process_output(output)

        end

        protected

        def runner(filename, *args)

          # Create new argument list
          opts = []

          # Add fixed options
          # -L : follow symlinks
          # --mime-type : only print MIME type
          opts << '-L' << '--mime-type'

          # Append passed arguments
          opts += args

          # Finally add the filename to process
          opts << filename.escape_for_string if filename

          # Run the UNIX file command and capture the results
          timeout = Libis::Format::Config[:timeouts][:file_tool]
          result = ::Libis::Tools::Command.run(
              'file', *opts,
              timeout: timeout,
              kill_after: timeout * 2
          )

          raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} errors: #{result[:err].join("\n")}" unless result[:status] == 0 && result[:err].empty?

          # Parse output text into array and return result
          result[:out].map do |line|
            r = line.split(/:\s+/)
            {filepath: r[0], mimetype: r[1], matchtype: 'magic', tool: :file}
          end
        end

      end

    end
  end
end
