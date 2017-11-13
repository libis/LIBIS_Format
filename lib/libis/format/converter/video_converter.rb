require_relative 'base'
require 'libis/format/ffmpeg'

require 'fileutils'

module Libis
  module Format
    module Converter

      class VideoConverter < Libis::Format::Converter::Base

        def self.input_types
          [:WEBM, :M4V, :MPEG, :MJP2, :QTFF, :AVI, :OGGV, :WMV, :DV, :FLASH]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:GIF, :AVI, :FLV, :MKV, :MOV, :MP4, :MPG, :OGGV, :SWF, :WEBM, :WMV]
        end

        def initialize
          super
        end

        def quiet(v)
          @flags[:quiet] = !!v
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

        def web_stream(value)
          if value
            @options[:video_codec] = 'h264'
            @options[:audio_codec] = 'acc'
          end
        end

        def preset(name)
          @options[:preset] = name
        end

        def audio_preset(name)
          @options[:audio_preset] = name
        end

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

            sources = Dir[File.join(source, '**', '*')].reject {|p| File.directory? p}
            assemble_and_convert(sources, target)

          else

            convert_file(source, target)

          end

          target

        end

        def assemble_and_convert(sources, target)
          Tempfile.create(%w(list .txt)) do |f|
            sources.each {|src| f.puts src}
            opts[:global] ||= []
            opts[:global] += %w(-f concat)
            f.close
            target = convert_file(f.to_path, target)
          end
          target
        end

        protected

        def convert_file(source, target)
          # FLV special: only supports aac and speex audio codecs
          format = (@options[:format] || File.extname(target)[1..-1]).to_s.downcase
          @options[:audio_codec] ||= 'aac' if %w'flv'.include?(format)

          # FLV special: only supports aac and speex audio codecs
          format = (@options[:format] || File.extname(target)[1..-1]).to_s.downcase
          @options[:audio_codec] ||= 'mp3' if %w'swf'.include?(format)

          # Set up FFMpeg command line parameters
          opts = {global: [], input: [], filter: [], output: []}
          opts[:global] << '-hide_banner'
          opts[:global] << '-loglevel' << (@options[:quiet] ? 'fatal' : 'warning')
          opts[:output] << '-ac' << @options[:audio_channels] if @options[:audio_channels]
          opts[:output] << '-c:a' << @options[:audio_codec] if @options[:audio_codec]
          opts[:output] << '-c:v' << @options[:video_codec] if @options[:video_codec]
          opts[:output] << '-b:a' << @options[:audio_bitrate] if @options[:audio_bitrate]
          opts[:output] << '-b:v' << @options[:video_bitrate] if @options[:video_bitrate]
          opts[:output] << '-crf' << @options[:crf] if @options[:crf]
          opts[:output] << '-map_metadata:g' << '0:g' # Copy global metadata
          opts[:output] << '-map_metadata:s:a' << '0:s:a' # Copy audio metadata
          opts[:output] << '-map_metadata:s:v' << '0:s:v' # Copy video metadata
          opts[:input] << '-accurate_seek' << (@options[:start].to_i < 0 ? '-sseof' : '-ss') << @options[:start] if @options[:start]
          opts[:input] << '-t' << @options[:duration] if @options[:duration]
          opts[:output] << '-qscale' << @options[:video_quality] if @options[:video_quality]
          opts[:output] << '-q:a' << @options[:audio_quality] if @options[:audio_quality]
          opts[:output] << '-r' << @options[:frame_rate] if @options[:frame_rate]
          opts[:output] << '-ar' << @options[:sampling_freq] if @options[:sampling_freq]
          opts[:output] << '-f' << @options[:format] if @options[:format]
          opts[:output] << '-pre' << @options[:preset] if @options[:preset]
          opts[:output] << '-apre' << @options[:audio_preset] if @options[:audio_preset]
          opts[:output] << '-vpre' << @options[:video_preset] if @options[:video_preset]
          result = Libis::Format::FFMpeg.run(source, target, opts)
          info "FFMpeg output: #{result}"
          target
        end

      end

    end
  end
end