require 'csv'
require 'tmpdir'

require 'singleton'
require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'
require 'libis/format/type_database'

module Libis
  module Format

    class IdentificationTool
      include Singleton
      include ::Libis::Tools::Logger

      def self.bad_mimetype(mimetype)
        self.instance.bad_mimetype(mimetype)
      end

      def self.run(file)
        self.instance.run file
      end

      def self.run_dir(file, recursive = true)
        self.instance.run_dir file, recursive
      end

      def self.run_list(file)
        self.instance.run_dir file
      end

      protected

      def create_list_file(filelist)
        list_file = Dir::Tmpname.create('file_list', Dir.tmpdir, 5) do |tmpfile, _, _|
          File.open(tmpfile, 'w') do |f|
            filelist.each do |fname|
              f.write "#{fname}\n"
            end
          end
        end
        yield(list_file)
      ensure
        File.delete(list_file)
      end

      def find_files(dir, recurse = true)
        args = []
        args << '-L'
        args << dir.escape_for_string
        args << '-maxdepth' << '1' unless recurse
        args << '-type' << 'f'
        args << '-print'
        output = ::Libis::Tools::Command.run('find', *args)
        warn "Find command errors: #{output[:err].join("\n")}" unless output[:err].empty?
        output[:out]
      end

      # Reformat output to make it easier to post-process and decide on the preferred format
      # final format:
      #   { <filename} =>
      #     { <score> => [<result>, ...]
      #       ...
      #     },
      #     ...
      #   }
      #
      # <result> is the Hash output of the identification tool:
      #   {filepath: <filepath>, mimetype: <mimetype>, puid: <puid>, }
      def process_output(output)
        results = {}

        output.each do |x|
          results[x[:filepath]] ||= []
          results[x[:filepath]] << annotate(x)
        end

        results.each_with_object({}) do |pair, hash|
          hash[pair[0]] = group_results(pair[1])
        end

      end

      # Enhance the output with mimetype and score
      def annotate(result)
        # Enhance result with mimetype if needed
        result[:mimetype] = get_mimetype(result[:puid]) if result[:mimetype] == 'None' && result[:puid] != nil

        # Default score is 5
        result[:score] = 5

        # Weak detection score is 1
        result[:score] = 1 if bad_mimetypes.include? result[:mimetype]

        # Adapt score based on matchtype
        result[:matchtype] = result[:matchtype].to_s.downcase
        case result[:matchtype]

          # Signature match increases score with 5
          when 'signature'
            result[:score] += 3

          # Container match increases score with 2 if extension matches type database
          when 'container'
            typeinfo = ::Libis::Format::TypeDatabase.puid_typeinfo(result[:puid])
            ext = File.extname(result[:filename])
            result[:score] += 5 if typeinfo and typeinfo[:EXTENSIONS].include?(ext)

          # Or no change otherwise
          else
            # do nothing
        end

        # Detecting a zip file should decrease the score as it may hide one of the many zip-based formats (e.g. epub,
        # Office OpenXML, OpenDocument, jar, maff, svx)
        if result[:mimetype] == 'application/zip'
          result[:score] -= 2
        end

        # Return result enhanced with mimetype and score fields
        result
      end

      def group_results(results)
        results.group_by {|x| x[:score]}.sort.reverse.to_h
      end

      def get_mimetype(puid)
        ::Libis::Format::TypeDatabase.puid_typeinfo(puid)[:MIME].first rescue nil
      end

      attr_accessor :bad_mimetypes

      def initialize
        @bad_mimetypes = [nil, '', 'None', 'application/octet-stream']
      end

      def bad_mimetype(mimetype)
        bad_mimetypes << mimetype
      end
    end

  end
end
