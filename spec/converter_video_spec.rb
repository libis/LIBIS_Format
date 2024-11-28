# frozen_string_literal: true

require 'spec_helper'

require 'libis/format/converter/video_converter'

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }

  before(:all) do
    Libis::Tools::Config.logger.level = 'off'
  end

  context 'Video Converter' do
    let(:converter) { Libis::Format::Converter::VideoConverter.new }
    extensions = %w[3gp avi flv mkv mov mp4 mpg swf webm wmv]
    targets = %w[avi flv mkv mov mp4 swf webm wmv gif]
    # noinspection RubyLiteralArrayInspection
    sources = %w[
      SampleVideo_176x144_2mb
      SampleVideo_320x240_2mb
      SampleVideo_360x240_2mb
      SampleVideo_1080x720_2mb
    ]
    bad_converts = []
    dir = File.join(data_dir, 'video')

    context 'converts' do
      sources.each do |source|
        context source do
          extensions.each do |ext|
            next unless File.exist?(File.join(dir, "#{source}.#{ext}"))

            (targets - [ext]).each do |tgt|
              next if bad_converts.include? [ext, tgt]

              it "#{ext} to #{tgt}" do
                src_file = File.join(dir, "#{source}.#{ext}")
                tgt_file = File.join(work_dir, "test.#{source}.#{ext}.#{tgt}")
                FileUtils.remove tgt_file, force: true
                FileUtils.mkdir_p File.dirname(tgt_file)
                converter.audio_channels(2) if %w[swf wmv].include?(tgt)
                converter.sampling_freq(44_100) if tgt == 'swf'
                if tgt == 'gif'
                  converter.start(1)
                  converter.duration(3)
                  converter.scale('100x100')
                end
                result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
                expect(result[:files].first).to eq tgt_file
                expect(File.size(tgt_file)).to be > 2000
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
          src_file = File.join(dir, source.to_s)
          tgt_file = File.join(work_dir, "test.#{source}_watermark_text.mp4")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.watermark_text '© LIBIS Format gem test'
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result[:files].first).to eq tgt_file
          expect(File.size(tgt_file)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end

        it "image with default options - #{source}" do
          src_file = File.join(dir, source.to_s)
          tgt_file = File.join(work_dir, "test.#{source}_watermark_image.mp4")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.watermark_image File.join(dir, 'copyright.png')
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result[:files].first).to eq tgt_file
          expect(File.size(tgt_file)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end

        it "text with KADOC style - #{source}" do
          src_file = File.join(dir, source.to_s)
          tgt_file = File.join(work_dir, "test.#{source}_watermark_kadoc.mp4")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.watermark_text 'KADOC-KU Leuven'
          converter.watermark_text_add_filename 1
          converter.watermark_text_size 'w/60'
          converter.watermark_text_color 'black'
          converter.watermark_opacity 0.5
          converter.watermark_position 'top_left'
          converter.watermark_offset_x '12'
          converter.watermark_offset_y '12'
          converter.watermark_text_shadow_offset 0
          converter.watermark_text_box 1
          converter.watermark_text_box_color '0x9FB6CD'
          converter.watermark_text_box_width '12'
          converter.watermark_blending 0.7
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result[:files].first).to eq tgt_file
          expect(File.size(tgt_file)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end

      end
    end

    context 'thumbnail' do
      # noinspection RubyLiteralArrayInspection
      [
        'SampleVideo_176x144_2mb.3gp',
        'SampleVideo_320x240_2mb.3gp',
        'SampleVideo_360x240_2mb.flv',
        'SampleVideo_360x240_2mb.mkv',
        'SampleVideo_1080x720_2mb.mp4'
      ].each do |source|
        it "default - #{source}" do
          src_file = File.join(dir, source.to_s)
          tgt_file = File.join(work_dir, "test.#{source}_thumbnail.gif")
          FileUtils.remove tgt_file, force: true
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.start 1
          converter.duration 5
          converter.scale '150x150'
          result = converter.convert(src_file, tgt_file, :MP4)
          expect(result[:files].first).to eq tgt_file
          expect(File.size(tgt_file)).to be > 2000
          FileUtils.remove tgt_file, force: true
        end
      end
    end

  end
end
