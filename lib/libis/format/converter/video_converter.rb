# frozen_string_literal: true

require_relative 'base'
require 'libis/format/tool/ff_mpeg'

require 'fileutils'

module Libis
  module Format
    module Converter
      class VideoConverter < Libis::Format::Converter::Base
        def self.input_types
          %i[WEBM MP4 MPG MKV MJP2 QTFF AVI OGGV WMV DV FLV SWF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)

          %i[GIF WEBM MP4 MPG MKV MJP2 QTFF AVI OGGV WMV DV FLV SWF]
        end

        def quiet(value)
          @flags[:quiet] = !!value
        end

        def format(format)
          @options[:format] = format
        end

        def audio_channels(value)
          @options[:audio_channels] = value.to_s
        end

        def audio_codec(codec)
          @options[:audio_codec] = codec
        end

        def video_codec(codec)
          @options[:video_codec] = codec
        end

        def start(seconds)
          @options[:start] = seconds.to_s
        end

        def duration(seconds)
          @options[:duration] = seconds.to_s
        end

        def audio_quality(value)
          @options[:audio_quality] = value.to_s
        end

        def video_quality(value)
          @options[:video_quality] = value.to_s
        end

        def audio_bitrate(value)
          @options[:audio_bitrate] = value.to_s
        end

        def video_bitrate(value)
          @options[:video_bitrate] = value.to_s
        end

        def constant_rate_factor(value)
          @options[:crf] = value.to_s
        end

        def frame_rate(value)
          @options[:frame_rate] = value.to_s
        end

        def sampling_freq(value)
          @options[:sampling_freq] = value.to_s
        end

        def scale(width_x_height)
          @options[:scale] = width_x_height
        end

        # @param [String] file Image file path to use as watermark
        def watermark_image(file)
          @options[:watermark_image] = file
        end

        # @param [String] value text for watermark. No watermark if nil (default)
        def watermark_text(value)
          @options[:watermark_text] = value
        end

        # @param [Integer] value Font size for watermark text. Default: 10
        # Note that the font is selected by the Config[:watermark_font] setting
        def watermark_text_size(value)
          @options[:watermark_text_size] = value.to_i
        end

        # @param [String] value Text color for the watermark text. Default: white
        def watermark_text_color(value)
          @options[:watermark_text_color] = value
        end

        # @param [String] value Text color for the watermark text shadow. Default: black
        def watermark_text_shadow_color(value)
          @options[:watermark_text_shadow_color] = value
        end

        # @param [Integer] value Offset of the watermark text shadow. Used for both x and y offset; default: 1
        # If the offset is set to 0, no shadow will be printed
        def watermark_text_shadow_offset(value)
          @options[:watermark_text_offset] = value.to_i
        end

        # @param [String] value one of 'bottom_left' (default), 'top_left', 'bottom_right', 'top_right', 'center'
        def watermark_position(value)
          @options[:watermark_position] = value
        end

        # @param [Number] value watermark opacity (0-1) with 0 = invisible and 1 = 100% opaque. Default: 0.5
        def watermark_opacity(value)
          @options[:watermark_opacity] = value.to_f
        end

        # @param [Boolean] value If set to true automatically selects optimal format for web viewing. Default: false
        def web_stream(value)
          return unless value

          @options[:video_codec] = 'h264'
          @options[:audio_codec] = 'acc'
        end

        # @param [String] name name of a preset. See FFMpeg documentation for more info
        def preset(name)
          @options[:preset] = name
        end

        # @param [String] name name of an audio preset. See FFMpeg documentation for more info
        def audio_preset(name)
          @options[:audio_preset] = name
        end

        # @param [String] name name of a video preset. See FFMpeg documentation for more info
        def video_preset(name)
          @options[:video_preset] = name
        end

        # def video_encoder(value)
        #   @options[:video_encoder] = value
        # end
        #
        # def audio_encoder(value)
        #   @options[:audio_encoder] = value
        # end
        #
        # def encoder_options(value)
        #   @options[:encoder_options] = value
        # end

        def convert(source, target, _format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          if source.is_a? Array

            assemble_and_convert(source, target)

          elsif File.directory?(source)

            sources = Dir[File.join(source, '**', '*')].reject { |p| File.directory? p }
            assemble_and_convert(sources, target)

          else

            convert_file(source, target)

          end

          {
            files: [target],
            converter: self.class.name
          }
        end

        def assemble_and_convert(sources, target)
          Tempfile.create(%w[list .txt]) do |f|
            sources.each { |src| f.puts src }
            opts[:global] ||= []
            opts[:global] += %w[-f concat]
            f.close
            target = convert_file(f.to_path, target)
          end
          target
        end

        protected

        def convert_file(source, target)
          # FLV special: only supports aac and speex audio codecs
          format = (@options[:format] || File.extname(target)[1..]).to_s.downcase
          @options[:audio_codec] ||= 'aac' if %w[flv].include?(format)

          # SWF special: only supports mp3 audio codec
          format = (@options[:format] || File.extname(target)[1..]).to_s.downcase
          @options[:audio_codec] ||= 'mp3' if %w[swf].include?(format)

          # Set up FFMpeg command line parameters
          opts = { global: [], input: [], filter: [], output: [] }
          opts[:global] << '-hide_banner'
          opts[:global] << '-loglevel' << (@options[:quiet] ? 'fatal' : 'warning')

          # Watermark info
          @options[:watermark_opacity] ||= 0.5
          if @options[:watermark_image]
            opts[:filter] << '-i' << @options[:watermark_image] << '-filter_complex'
            opts[:filter] << Kernel.format('[1:v]format=argb,colorchannelmixer=aa=%f[wm];[0:v][wm]overlay=%s',
                                           @options[:watermark_opacity], watermark_position_text)
          elsif @options[:watermark_text]
            @options[:watermark_text_size] ||= 10
            @options[:watermark_text_color] ||= 'white'
            @options[:watermark_text_shadow_color] ||= 'black'
            @options[:watermark_text_shadow_offset] ||= 1
            filter_text = Kernel.format("drawtext=text='%s':%s:fontfile=%s:fontsize=%d:fontcolor=%s@%f",
                                        @options[:watermark_text], watermark_position_text(true), Config[:watermark_font],
                                        @options[:watermark_text_size], @options[:watermark_text_color], @options[:watermark_opacity])
            if (@options[:watermark_text_shadow_offset]).positive?
              filter_text += Kernel.format(':shadowcolor=%s@%f:shadowx=%d:shadowy=%d',
                                           @options[:watermark_text_shadow_color], @options[:watermark_opacity],
                                           @options[:watermark_text_shadow_offset], @options[:watermark_text_shadow_offset])
            end
            opts[:filter] << '-vf' << filter_text
          end
          opts[:output] << '-ac' << @options[:audio_channels] if @options[:audio_channels]
          opts[:output] << '-c:a' << @options[:audio_codec] if @options[:audio_codec]
          opts[:output] << '-c:v' << @options[:video_codec] if @options[:video_codec]
          opts[:output] << '-b:a' << @options[:audio_bitrate] if @options[:audio_bitrate]
          opts[:output] << '-b:v' << @options[:video_bitrate] if @options[:video_bitrate]
          opts[:output] << '-crf' << @options[:crf] if @options[:crf]
          opts[:output] << '-map_metadata:g' << '0:g' # Copy global metadata
          opts[:output] << '-map_metadata:s:a' << '0:s:a' # Copy audio metadata
          opts[:output] << '-map_metadata:s:v' << '0:s:v' # Copy video metadata
          opts[:input] << '-accurate_seek' << (@options[:start].to_i.negative? ? '-sseof' : '-ss') << @options[:start] if @options[:start]
          opts[:input] << '-t' << @options[:duration] if @options[:duration]
          opts[:output] << '-qscale' << @options[:video_quality] if @options[:video_quality]
          opts[:output] << '-q:a' << @options[:audio_quality] if @options[:audio_quality]
          opts[:output] << '-r' << @options[:frame_rate] if @options[:frame_rate]
          opts[:output] << '-ar' << @options[:sampling_freq] if @options[:sampling_freq]
          if @options[:scale]
            scale = @options[:scale].split('x')
            width = scale[0]
            height = scale[1]
            opts[:output] << '-vf' << "scale=w=#{width}:h=#{height}:force_original_aspect_ratio=decrease"
          end
          opts[:output] << '-f' << @options[:format] if @options[:format]
          opts[:output] << '-pre' << @options[:preset] if @options[:preset]
          opts[:output] << '-apre' << @options[:audio_preset] if @options[:audio_preset]
          opts[:output] << '-vpre' << @options[:video_preset] if @options[:video_preset]
          info "FFMpeg options: #{opts}"
          result = Libis::Format::Tool::FFMpeg.run(source, target, opts)
          info "FFMpeg output: #{result}"
          target
        end

        def watermark_position_text(for_text = false, margin = 10)
          w = for_text ? 'tw' : 'w'
          h = for_text ? 'th' : 'h'
          case @options[:watermark_position]
          when 'bottom_left'
            "x=#{margin}:y=H-#{h}-#{margin}"
          when 'top_left'
            "x=#{margin}:y=#{margin}"
          when 'bottom_right'
            "x=W-#{w}-#{margin}:y=H-#{h}-#{margin}"
          when 'top_right'
            "x=W-#{w}-#{margin}:y=#{margin}"
          else
            "x=#{margin}:y=H-#{h}-#{margin}"
          end
        end
      end
    end
  end
end
