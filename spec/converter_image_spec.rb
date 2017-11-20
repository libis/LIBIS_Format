# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/image_converter'
require 'libis/format/converter/jp2_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Image Converter' do

    let(:converter) {Libis::Format::Converter::ImageConverter.new}
    let(:diff_file) {File.join('', 'tmp', 'diff.jpg')}

    it 'converts TIFF to JPEG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.jpg')
      tgt_file = File.join('', 'tmp', 'test.jpg')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '1%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.png')
      tgt_file = File.join('', 'tmp', 'test.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :PNG)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts PDF to TIFF' do
      src_file = File.join(file_dir, 'data', 'test.pdf')
      ref_file = File.join(file_dir, 'data', 'test.pdf.tif')
      tgt_file = File.join('', 'tmp', 'test.pdf.tif')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :TIFF)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '100%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG with many options' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test-options.png')
      tgt_file = File.join('', 'tmp', 'test-options.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark(text: 'RSPEC', size: 5, opacity: 0.1, rotation: 15, gap: 0.5, composition: 'modulate')
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :PNG, options: {scale: '150%'})
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '100%'
      compare << diff_file
      compare.call do |_stdin, _stdout, status|
        expect(status).to be 0
      end
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts only first page of multipage TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'multipage.tif')
      ref_file = File.join(file_dir, 'data', 'multipage.tif.jp2')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.quiet(true)
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end


  end

  context 'JP2 Converter', if: File.exists?(Libis::Format::Config[:j2kdriver]) do

    let(:converter) {Libis::Format::Converter::Jp2Converter.new}
    let(:diff_file) {File.join('', 'tmp', 'diff.jpg')}

    it 'converts TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end

    it 'converts only first page of multipage TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'multipage.tif')
      ref_file = File.join(file_dir, 'data', 'multipage.tif.jp2')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

  end

end
