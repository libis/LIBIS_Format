# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/video_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Video Converter' do

    let(:converter) {Libis::Format::Converter::VideoConverter.new}
    extensions = %w'3gp avi flv mkv mov mp4 mpg swf webm wmv'
    targets = %w'avi flv mkv mov mp4 swf webm wmv gif'
    # noinspection RubyLiteralArrayInspection
    sources = [
        'SampleVideo_176x144_2mb',
        'SampleVideo_320x240_2mb',
        'SampleVideo_360x240_2mb',
        'SampleVideo_1080x720_2mb'
    ]
    bad_converts = [
    ]
    dir = File.join(data_dir, 'video')

    context 'converts' do
      sources.each do |source|
        context source do
          extensions.each do |ext|
            next unless (File.exists?(File.join(dir, "#{source}.#{ext}")))
            (targets - [ext]).each do |tgt|
              next if bad_converts.include? [ext, tgt]
              it "#{ext} to #{tgt}" do
                src_file = File.join(dir, "#{source}.#{ext}")
                tgt_file = File.join('', 'tmp', "test.#{source}.#{ext}.#{tgt}")
                FileUtils.remove tgt_file, force: true
                FileUtils.mkdir_p File.dirname(tgt_file)
                converter.audio_channels(2) if %w'swf wmv'.include?(tgt)
                converter.sampling_freq(44100) if tgt == 'swf'
                if tgt == 'gif'
                  converter.start(1)
                  converter.duration(3)
                  converter.scale('100x100')
                end
                result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
                expect(result).to eq tgt_file
                expect(File.size(result)).to be > 2000
                FileUtils.remove tgt_file, force: true
              end
            end
          end
        end
      end
    end

    context 'watermark' do
      # noinspection RubyLiteralArrayInspection
      [
          'SampleVideo_176x144_2mb.3gp',
          'SampleVideo_320x240_2mb.3gp',
          'SampleVideo_360x240_2mb.mp4',
          'SampleVideo_1080x720_2mb.mp4'
      ].each do |source|
        it "text with default options - #{source}" do
          src_file = File.join(dir, "#{source}")
          tgt_file = File.join('', 'tmp', "test.#{source}_watermark.mp4")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.watermark_text '© LIBIS Format gem test'
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result).to eq tgt_file
          expect(File.size(result)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end

        it "image with default options - #{source}" do
          src_file = File.join(dir, "#{source}")
          tgt_file = File.join('', 'tmp', "test.#{source}_watermark_image.mp4")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.watermark_image File.join(dir, 'copyright.png')
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result).to eq tgt_file
          expect(File.size(result)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end
      end
    end

  end

end
