require_relative 'base'
require 'libis/format/identifier'
require 'chromaprint'

require 'fileutils'

module Libis
  module Format
    module Converter

      class AudioConverter < Libis::Format::Converter::Base

        def self.input_types
          [:MP3, :FLAC, :AC3, :AAC, :WMA, :ALAC, :WAV, :AIFF, :AMR, :AU, :M4A]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:MP3, :FLAC, :AC3, :AAC, :WMA, :ALAC, :WAV, :AIFF, :AMR, :AU, :M4A]
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

        def codec(codec)
          @options[:codec] = codec
        end

        def start(seconds)
          @options[:start] = seconds.to_s
        end

        def duration(seconds)
          @options[:duration] = seconds.to_s
        end

        def quality(value)
          @options[:quality] = value.to_s
        end

        def bit_rate(value)
          @options[:bit_rate] = value.to_s
        end

        def sampling_freq(value)
          @options[:sampling_freq] = value.to_s
        end

        def channels(value)
          @options[:channels] = value.to_s
        end

        def web_stream(value)
          if value
            @options[:codec] = 'mp3'
          end
        end

        def preset(stream, name)
          (@options[:preset] ||= {})[stream] = name
        end

        # def encoder(value)
        #   @options[:encoder] = value
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

        def self.sounds_like(file1, file2, threshold, rate, channels)
          rate ||= 96000
          channels ||= 2
          threshold ||= 0.85

          if File.exists?(file1) && File.exists?(file2)
            # Convert input files into raw 16-bit signed audio (WAV) to process with Chramaprint
            file1_raw = File.join('', 'tmp', File.basename(file1) + '.wav')
            file2_raw = File.join('', 'tmp', File.basename(file2) + '.wav')
            FileUtils.rm(file1_raw, force: true)
            FileUtils.rm(file2_raw, force: true)
            cvt_cmd = Libis::Format::Config[:raw_audio_convert_cmd]
            %x"#{cvt_cmd % [file1, file1_raw, rate, channels]}"
            %x"#{cvt_cmd % [file2, file2_raw, rate, channels]}"
            file1_audio = File.binread(file1_raw)
            file2_audio = File.binread(file2_raw)

            # Get audio fingerprints
            chromaprint = Chromaprint::Context.new(rate, channels, Chromaprint::ALGORITHM_TEST3)
            file1_fp = chromaprint.get_fingerprint(file1_audio)
            file2_fp = chromaprint.get_fingerprint(file2_audio)

            # Cleanup files
            FileUtils.rm(file1_raw, force: true)
            FileUtils.rm(file2_raw, force: true)

            # Compare fingerprints and compare result against threshold
            cmp = file1_fp.compare(file2_fp)
            # puts "Threshold[#{File.basename(exp_file)},#{File.basename(tgt_file)}: #{cmp}"
            cmp > threshold
          else
            false
          end

        rescue Exception => e
          error "Error comparing sound file #{file1} and #{file2}: #{e.message} @ #{e.backtrace.first}"
          false
        end

        protected

        def convert_file(source, target)
          opts = {global: [], input: [], filter: [], output: []}
          opts[:global] << '-hide_banner'
          opts[:global] << '-loglevel' << (@options[:quiet] ? 'fatal' : 'warning')
          opts[:output] << '-vn' # disable input video stream in case it exists
          opts[:output] << '-codec:a' << @options[:codec] if @options[:codec]
          opts[:output] << '-map_metadata:g' << '0:g' # Copy global metadata
          opts[:output] << '-map_metadata:s:a' << '0:s:a' # Copy audio metadata
          opts[:input] << '-accurate_seek' << (@options[:start].to_i < 0 ? '-sseof' : '-ss') << @options[:start] if @options[:start]
          opts[:input] << '-t' << @options[:duration] if @options[:duration]
          opts[:output] << '-q:a' << @options[:quality] if @options[:quality]
          opts[:output] << '-b:a' << @options[:bit_rate] if @options[:bit_rate]
          opts[:output] << '-ar' << @options[:sampling_freq] if @options[:sampling_freq]
          opts[:output] << '-ac' << @options[:channels] if @options[:channels]
          opts[:output] << '-f' << @options[:format] if @options[:format]
          result = Libis::Format::Tool::FFMpeg.run(source, target, opts)
          info "FFMpeg output: #{result}"
          result
          target
        end

      end

    end
  end
end