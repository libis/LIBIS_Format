require 'libis/tools/extend/string'
require 'libis/tools/command'

require_relative 'identification_tool'

module Libis
  module Format

    class FileTool < Libis::Format::IdentificationTool

      protected

      def run_list(filelist)

        create_list_file(filelist) do |list_file|

          output = runner(nil, '--files-from', list_file)

          process_output(output)

        end

      end

      def run_dir(dir, recursive = true)

        filelist = find_files(dir, recursive)

        create_list_file(filelist) do |list_file|

          output = runner(nil, '--files-from', list_file)

          process_output(output)

        end

      end

      def run(file)

        output = runner(file)
        process_output(output)
      end

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
        file_tool = ::Libis::Tools::Command.run('file', *opts)

        warn "File command errors: #{file_tool[:err].join("\n")}" unless file_tool[:err].empty?

        # Parse output text into array and return result
        file_tool[:out].map do |line|
          r = line.split(/:\s+/)
          {filepath: r[0], mimetype: r[1], matchtype: 'signature', source: :file}
        end
      end

    end

  end
end
