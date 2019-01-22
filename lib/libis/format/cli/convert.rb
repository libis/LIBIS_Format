require 'awesome_print'
require 'libis-format'
require 'libis-tools'
require 'libis/tools/extend/hash'
require 'fileutils'
require 'tmpdir'
require 'yaml'

require 'libis/format/converter/image_converter'

require_relative 'sub_command'

module Libis
  module Format
    module Cli
      class Convert < SubCommand

        no_commands do
          def self.description(field)
            "#{STRING_CONFIG[field]}." + (DEFAULT_CONFIG[field].nil? ? '' : " default: #{DEFAULT_CONFIG[field]}")
          end
        end

        DEFAULT_CONFIG = {
            scale: '100%',
            resize: '100%',
            wm_tiles: 4,
            wm_resize: 1.0,
            wm_gap: 0.2,
            wm_rotation: 30,
            wm_opacity: 0.1,
            wm_gravity: 'center',
            wm_composition: 'modulate'
        }

        STRING_CONFIG = {
            page: 'Page number to select for multipage documents',
            quiet: 'suppress all warning messages. Error messages are still reported',
            scale: 'minify / magnify the image with pixel block averaging and pixel replication, respectively',
            resize: 'Resize the image',
            resample: 'Resize the image so that its rendered size remains the same as the original at the specified target resolution',
            flatten: 'Create a canvas the size of the first images virtual canvas using the current -background color, and -compose each image in turn onto that canvas. Images falling outside that canvas is clipped',
            delete_date: 'Remove modified date and created date metadata from the target image',
            colorspace: 'Set the image colorspace',
            profile: 'Specify color profile used for the image',
            wm_text: 'Create watermark with given text',
            wm_file: 'Create watermark from given file',
            wm_tiles: 'Number of tiles of the watermark to distribute over the image. 0: no tiling, 1: watermark image scaled to fit image, n>1: at least n tiles horizontally/vertically, n<0: tile without recaling',
            wm_resize: 'Resize the watermark image (fraction 0.0 - 1.0)',
            wm_gap: 'Leave n % of whitespace between the watermark images. Similar effect can be achieved with wm_resize',
            wm_rotation: 'Rotate the watermark text n degrees counterclockwise (0-360)',
            wm_opacity: 'Opacity of the watermark (fraction 0.0 - 1.0)',
            wm_gravity: 'Center point of the watermark overlay',
            wm_composition: 'Set the type of image composition'
        }

        desc 'auto SOURCE TARGET [options]', 'Convert SOURCE file to TARGET file using auto algorithm'
        long_desc <<-DESC
  
        'auto SOURCE TARGET [options]' will convert a file according to the best conversion chain algorithm.

        A source file name and target file name should be supplied. The source file should exist and be readable.
        The target file should be writable, but should not exist.

        Optionally an options file name can be added to the command line. The options file should be a valid YAML
        file that contains either a Hash or an Array of Hashes. The content should contain the required methods and 
        arguments that any of the targetted converters support.

        The source file's format will be identified by the Libis::Format::Identifier and the target file's format
        will be derived from the file's extension. The Libis::Format::TypeDatabase is used to relate extensions
        with formats.

        DESC

        method_option :options, aliases: '-o', desc: 'Options file'

        def auto(source_file, target_file)
          options_file = options[:options]
          opts = check_input(source_file, target_file, options_file)
          output, converter = do_convert(source_file, target_file, opts)
          prompt.ok "Output file '#{output}' created with converter #{converter}."
        end

        desc 'image SOURCE TARGET [options]', 'Convert SOURCE image to TARGET image using ImageConverter'
        long_desc <<-DESC

            'image SOURCE TARGET [options]' will convert a SOURCE image to TARGET image using the ImageConverter.

            A source file name and target file name should be supplied. The source file should exist and be readable.
            The target file should be writable, but should not exist.

            The target file's format will be derived from the file's extension. The Libis::Format::TypeDatabase is used 
            to relate extensions with formats.

        DESC

        method_option :page, type: :numeric, aliases: '-p', desc: description(:page)
        method_option :quiet, type: :boolean, aliases: '-q', desc: description(:quiet)
        method_option :scale, type: :numeric, aliases: '-c', desc: description(:scale)
        method_option :resize, type: :numeric, aliases: '-r', desc: description(:resize)
        method_option :resample, type: :numeric, aliases: '-m', desc: description(:resample)
        method_option :flatten, type: :boolean, aliases: '-f', desc: description(:flatten)
        method_option :delete_date, type: :boolean, aliases: '-dd', desc: description(:delete_date)
        method_option :colorspace, aliases: '-cs', desc: description(:colorspace)
        method_option :profile, aliases: '-prof', desc: description(:profile)
        method_option :wm_text, desc: description(:wm_text)
        method_option :wm_file, desc: description(:wm_file)
        method_option :wm_tiles, type: :numeric, desc: description(:wm_tiles)
        method_option :wm_resize, type: :numeric, desc: description(:wm_resize)
        method_option :wm_gap, type: :numeric, desc: description(:wm_gap)
        method_option :wm_rotation, type: :numeric, desc: description(:wm_rotation)
        method_option :wm_opacity, type: :numeric, desc: description(:wm_opacity)
        method_option :wm_gravity, desc: description(:wm_gravity)
        method_option :wm_composition, desc: description(:wm_composition)

        def image(source_file, target_file)
          check_input(source_file, target_file)
          convert_image(source_file, target_file)
          prompt.ok "Output file '#{target_file}' created with image converter."
        end

        protected

        def do_convert(source_file, target_file, opts)
          format_info = format_identifier(source_file)
          src_mime = format_info[:mimetype]
          source_format = format_info[:TYPE]
          unless source_format
            prompt.error "File item %s format (#{src_mime}) is not supported."
            exit
          end
          target_format = get_format(target_file)
          converterlist = []
          temp_files = []
          opts.each do |o|
            o = o.dup
            tgt_format = o.delete(:target_format) || target_format
            tgt_file = tempname(source_file, tgt_format)
            temp_files << tgt_file
            begin
              source_file, converter = convert_file(source_file, tgt_file, source_format, tgt_format, o)
            rescue Exception => e
              prompt.error "File conversion of '%s' from '%s' to '%s' failed: %s @ %s" %
                               [source_file, source_format, tgt_format, e.message, e.backtrace.first]
              exit
            end
            source_format = tgt_format
            converterlist << converter
          end
          converter = converterlist.join(' + ')
          if target_file
            FileUtils.mkpath(File.dirname(target_file))
            FileUtils.copy(source_file, target_file)
          else
            target_file = temp_files.pop
          end
          temp_files.each {|tmp_file| FileUtils.rm_f tmp_file}
          [target_file, converter]
        end

        def convert_file(src_file, tgt_file, src_format, tgt_format, opts)
          converter = Libis::Format::Converter::Repository.get_converter_chain(src_format, tgt_format, opts)

          unless converter
            prompt.error "Could not find converter for #{src_format} -> #{tgt_format} with #{opts}"
            exit
          end

          converter_name = converter.to_s
          prompt.say 'Converting file %s to %s with %s ' % [src_file, tgt_file, converter_name]
          converted = converter.convert(src_file, tgt_file)

          unless converted && converted == tgt_file
            prompt.error 'File conversion failed (%s).', converter_name
            return [nil, converter_name]
          end

          [tgt_file, converter_name]
        end

        def convert_image(source_file, target_file)
          target_format = get_format(target_file)
          converter = Libis::Format::Converter::ImageConverter.new
          converter.page options[:page] if options[:page]
          converter.quiet options[:quiet] if options[:quiet]
          converter.scale options[:scale] if options[:scale]
          converter.resize options[:resize] if options[:resize]
          converter.resample options[:resample] if options[:resample]
          converter.flatten if options[:flatten]
          converter.delete_date if options[:delete_date]
          converter.colorspace options[:colorspace] if options[:colorspace]
          converter.profile options[:profile] if options[:profile]
          if options[:wm_text] || options[:wm_file]
            wm_options = {}
            wm_options[:text] = options[:wm_text] if options[:wm_text]
            wm_options[:file] = options[:wm_file] if options[:wm_file]
            wm_options[:tiles] = options[:wm_tiles] if options[:wm_tiles]
            wm_options[:resize] = options[:wm_resize] if options[:wm_resize]
            wm_options[:gap] = options[:wm_gap] if options[:wm_gap]
            wm_options[:rotation] = options[:wm_rotation] if options[:wm_rotation]
            wm_options[:opacity] = options[:wm_opacity] if options[:wm_opacity]
            wm_options[:gravity] = options[:wm_gravity] if options[:wm_gravity]
            wm_options[:composition] = options[:wm_composition] if options[:wm_composition]
            converter.watermark(wm_options)
          end
          converter.convert source_file, target_file, target_format
        end

        private

        def check_input(source_file, target_file, options_file = nil)
          # Check if source file exists and can be read
          unless source_file && File.exist?(source_file) && File.readable?(source_file)
            prompt.error "Fatal error trying to access source file '#{source_file}'."
            exit
          end
          # Check if target file argument is supplied
          unless target_file
            prompt.error "Fatal error: no target file name supplied."
            exit
          end
          # Check if target file directory can be created
          begin
            FileUtils.mkdir_p(File.dirname(target_file))
          rescue SystemCallError => e
            prompt.error "Fatal error trying to create folder for target file: #{e.message}"
            exit
          end

          return [{}] unless options_file

          # Check if options file exists and can be read
          unless File.exist?(options_file) && File.readable?(options_file)
            prompt.error "Fatal error trying to access options file '#{options_file}'."
            exit
          end

          begin
            opts = ::YAML.load_file(options_file)
            opts = case opts
                   when Hash
                     [opts]
                   when Array
                     opts
                   when NilClass
                     [{}]
                   else
                     prompt.error "Options file contents should be a Hash or an Array of Hashes."
                     exit
                   end
            opts.each {|h| h.key_strings_to_symbols!(recursive: true)}
            opts
          rescue Exception => e
            prompt.error "Fatal error trying to parse options file: #{e.message}"
            exit
          end

        end

        def tempname(source_file, target_format)
          # noinspection RubyResolve
          Dir::Tmpname.create(
              [File.basename(source_file, '.*'), ".#{extname(target_format)}"]
          ) {}
        end

        def extname(format)
          Libis::Format::TypeDatabase.type_extentions(format).first
        end

        def get_format(file_name)
          Libis::Format::TypeDatabase.ext_types(File.extname(file_name)).first
        end

        def format_identifier(file)
          prompt.say "Identifying format of file '#{file}'"
          result = Libis::Format::Identifier.get(file) || {}
          process_messages(result)
          format = result[:formats][file]
          unless format[:mimetype]
            prompt.warn "Could not determine MIME type. Using default 'application/octet-stream'."
            result[:puid] ||= 'fmt/unknown'
          end
          prompt.say "#{file} format: #{format[:GROUP]}, #{format[:TYPE]} (puid: #{format[:puid]}) mimetype: #{format[:mimetype]}"
          format
        end

        def process_messages(format_result)
          format_result[:messages].each do |msg|
            case msg[0]
            when :debug
              prompt.say msg[1]
            when :info
              prompt.say msg[1]
            when :warn
              prompt.warn msg[1]
            when :error
              prompt.error msg[1]
            when :fatal
              prompt.error msg[1]
            else
              prompt.say "#{msg[0]}: #{msg[1]}"
            end
          end
        end

      end
    end
  end
end