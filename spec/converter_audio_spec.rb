# frozen_string_literal: true

require 'spec_helper'

require 'libis/format/converter/audio_converter'

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }
  let(:work_dir) { File.join(data_dir, '..', 'work') }

  before(:all) do
    Libis::Tools::Config.logger.level = 'off'
  end

  context 'Audio Converter' do
    let(:converter) { Libis::Format::Converter::AudioConverter.new }
    extensions = %w[aac aiff au flac m4a mka mp3 ra voc wav wma]
    confidence = {
      aac: 0.86,
      aiff: 0.99,
      au: 0.99,
      flac: 0.99,
      m4a: 0.93,
      mka: 0.94,
      mp3: 0.95,
      ra: 0.92,
      voc: 0.99,
      wav: 0.99,
      wma: 0.9
    }
    targets = %w[mp3 flac wav]
    quality = {
      greensleeves: 0.95,
      top_gun_secret: 0.95
    }

    dir = File.join(data_dir, 'audio')
    sources = Dir.glob(File.join(dir, '*')).map { |f| File.basename(f, '.*') }.sort.uniq

    context 'converts' do
      sources.each do |source|
        extensions.each do |ext|
          next unless File.exist?(File.join(dir, "#{source}.#{ext}"))

          (targets - [ext]).each do |tgt|
            it "#{source} #{ext} to #{tgt}" do
              src_file = File.join(dir, "#{source}.#{ext}")
              ref_file = File.join(dir, "#{source}.#{tgt}")
              tgt_file = File.join(work_dir, "test.#{source}.#{ext}.#{tgt}")
              FileUtils.remove tgt_file, force: true
              FileUtils.mkdir_p File.dirname(tgt_file)
              result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
              expect(result[:command][:status]).to eq 0
              expect(result[:files].first).to eq tgt_file
              expect(tgt_file).to sound_like ref_file, confidence[ext.to_sym] * (quality[source.to_sym] || 1.0), 11_025, 1
              FileUtils.remove tgt_file, force: true
            end
          end
        end
      end
    end
  end
end
