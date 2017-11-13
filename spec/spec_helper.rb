require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'rspec'
require 'libis-format'
require 'libis-tools'

require 'chromaprint'

RSpec::Matchers.define(:be_same_file_as) do |exected_file_path|
  match do |actual_file_path|
    expect(md5_hash(actual_file_path)).to eq md5_hash(exected_file_path)
  end

  def md5_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path))
  end
end

RSpec::Matchers.define :sound_like do |exp_file, threshold, rate, channels|
  match do |tgt_file|
    rate ||= 96000
    channels ||= 1
    threshold ||= 0.9

    if File.exists?(exp_file) && File.exists?(tgt_file)
      # Convert input files into raw 16-bit signed audio (WAV) to process with Chramaprint
      exp_raw = File.join('','tmp', File.basename(exp_file) + '.wav')
      tgt_raw = File.join('','tmp', File.basename(tgt_file) + '.wav')
      FileUtils.rm(exp_raw, force: true)
      FileUtils.rm(tgt_raw, force: true)
      cvt_cmd = "sox %s -e signed -b 16 -t wav %s rate #{rate} channels #{channels}"
      %x"#{cvt_cmd % [exp_file,exp_raw]}"
      %x"#{cvt_cmd % [tgt_file,tgt_raw]}"
      exp_audio = File.binread(exp_raw)
      tgt_audio = File.binread(tgt_raw)

      # Get audio fingerprints
      chromaprint = Chromaprint::Context.new(rate, channels, Chromaprint::ALGORITHM_TEST3)
      exp_fp = chromaprint.get_fingerprint(exp_audio)
      tgt_fp = chromaprint.get_fingerprint(tgt_audio)

      # Cleanup files
      FileUtils.rm(exp_raw, force: true)
      FileUtils.rm(tgt_raw, force: true)

      # Compare fingerprints and compare result against threshold
      cmp = exp_fp.compare(tgt_fp)
      # puts "Threshold[#{File.basename(exp_file)},#{File.basename(tgt_file)}: #{cmp}"
      cmp > threshold
    else
      false
    end
  end
end
