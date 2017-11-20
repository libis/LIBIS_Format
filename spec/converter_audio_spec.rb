# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/audio_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Audio Converter' do

    let(:converter) {Libis::Format::Converter::AudioConverter.new}
    extensions = %w'aac aiff au flac m4a mka mp3 ra voc wav wma'
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
    targets = %w'mp3 flac wav'
    sources = %w'carlin_disappointed greensleeves king_nonviolence top_gun_secret'
    quality = {
        carlin_disappointed: 1.0,
        greensleeves: 0.95,
        king_nonviolence: 1.0,
        top_gun_secret: 0.95
    }

    let(:data_dir) {File.join(file_dir, 'data', 'audio')}

    context 'converts' do
      sources.each do |source|
        extensions.each do |ext|
          next unless (File.exists?(File.join(File.dirname(__FILE__), 'data', 'audio', "#{source}.#{ext}")))
          (targets - [ext]).each do |tgt|
            it "#{source} #{ext} to #{tgt}" do
              src_file = File.join(data_dir, "#{source}.#{ext}")
              ref_file = File.join(data_dir, "#{source}.#{tgt}")
              tgt_file = File.join('', 'tmp', "test.#{source}.#{ext}.#{tgt}")
              FileUtils.remove tgt_file, force: true
              FileUtils.mkdir_p File.dirname(tgt_file)
              result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
              expect(result).to eq tgt_file
              expect(result).to sound_like ref_file, confidence[ext.to_sym] * quality[source.to_sym], 11025, 1
              FileUtils.remove tgt_file, force: true
            end
          end
        end
      end
    end

  end

end
