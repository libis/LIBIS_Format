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
    module Tool

        class IdentificationTool
        include Singleton
        include ::Libis::Tools::Logger

        def self.bad_mimetype(mimetype)
          self.instance.bad_mimetype(mimetype)
        end

        def self.run(file, recursive = false)
          if file.is_a?(Array)
            return run_list file
          elsif file.is_a?(String) && File.exists?(file) && File.readable?(file)
            if File.directory?(file)
              return run_dir(file, recursive)
            elsif File.file?(file)
              return self.instance.run(file)
            end
          end
          raise ArgumentError,
                'IdentificationTool: file argument should be a path to an existing file or directory or a list of those'
        end

        def self.run_dir(file, recursive = true)
          self.instance.run_dir file, recursive
        end

        def self.run_list(filelist)
          self.instance.run_list filelist
        end

        protected

        def create_list_file(filelist)
          list_file = Tempfile.new(%w'file .list')
          filelist.each do |fname|
            list_file.write "#{fname}\n"
          end
          list_file.close
          yield(list_file.path)
        ensure
          list_file.unlink
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
        #
        # input format:
        # [
        #   { filepath: <filename>, mimetype: <mimetype>, matchtype: <matchtype>, ... }
        # ]
        #
        # output format:
        #   { <filename> => [<result>, ...], ... }
        #
        # <result> is the enchanced Hash output of the identification tool:
        #   { mimetype: <mimetype>, puid: <puid>, matchtype: <matchtype>, score: <score>, ...}
        #
        def process_output(output)
          output.reduce({}) do |results, x|
            filepath = x.delete(:filepath)
            results[filepath] ||= []
            results[filepath.freeze] << annotate(x)
            results
          end
        end

        # Enhance the output with mimetype and score
        def annotate(result)
          # Enhance result with mimetype if needed
          if bad_mimetypes.include?(result[:mimetype]) && !bad_puids.include?(result[:puid])
            result[:mimetype] = get_mimetype(result[:puid])
          end

          # Normalize the mimetype
          Libis::Format::TypeDatabase.normalize(result, PUID: :puid, MIME: :mimetype)

          # Default score is 5
          result[:score] = 5

          # Weak detection score is 1
          result[:score] = 1 if bad_mimetypes.include? result[:mimetype]

          # freeze all strings
          result.each {|_, v| v.freeze if v.is_a?(String)}

          # Adapt score based on matchtype
          result[:matchtype] = result[:matchtype].to_s.downcase
          case result[:matchtype]

            # Signature match increases score with 2
            when 'signature'
              result[:score] += 2
            # typeinfo = ::Libis::Format::TypeDatabase.puid_typeinfo(result[:puid])
            # ext = File.extname(result[:filename])
            # result[:score] += 1 if typeinfo and typeinfo[:EXTENSIONS].include?(ext)

            # Container match increases score with 4
            when 'container'
              result[:score] += 4
            # typeinfo = ::Libis::Format::TypeDatabase.puid_typeinfo(result[:puid])
            # ext = File.extname(result[:filename])
            # result[:score] += 1 if typeinfo and typeinfo[:EXTENSIONS].include?(ext)

            # Extension match is the weakest identification; score is lowered by 2 points
            when 'extension'
              result[:score] -= 2

            # Magic code (file tool) is to be trused even less
            when 'magic'
              result[:score] -= 3

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

        def get_mimetype(puid)
          ::Libis::Format::TypeDatabase.puid_typeinfo(puid)[:MIME].first rescue nil
        end

        def get_puid(mimetype)
          ::Libis::Format::TypeDatabase.mime_infos(mimetype).first[:PUID].first rescue nil
        end

        attr_accessor :bad_mimetypes, :bad_puids

        def initialize
          @bad_mimetypes = [nil, '', 'None', 'application/octet-stream']
          @bad_puids = [nil, 'fmt/unknown']
        end

        def bad_mimetype(mimetype)
          @bad_mimetypes << mimetype
        end
      end

    end
  end
end
