# frozen_string_literal: true

require 'spec_helper'

require 'libis/format/converter/image_converter'
require 'libis/format/converter/jp2_converter'

RSpec.shared_examples 'an image watermark' do |source_format, target_format|

  let (:src_file) { File.join(data_dir, "test.#{source_format}")}
  let (:tgt_file) { File.join(work_dir, "test_#{source_format}_wm_#{variant}.#{target_format}") }
  let (:ref_file) { File.join(data_dir, "image", "test_#{source_format}_wm_#{variant}.#{target_format}") }

  context 'with text' do
    let (:variant) { 'text' }

    it 'watermark' do
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark text: 'LIBIS'
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '1%'
      compare << diff_file
      compare.call do |_stdin, _stdout, status|
        expect(status).to be 0
      end
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end
  end

  context 'with image' do
    let (:variant) { 'image' }

    it 'watermark' do
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark image: File.join(data_dir, 'test.jpg'), rotation: 30
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '1%'
      compare << diff_file
      compare.call do |_stdin, _stdout, status|
        expect(status).to be 0
      end
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end
  end

  context 'with banner' do
    let (:variant) { 'banner' }

    it 'watermark' do
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark banner: 'Test banner for: ', add_filename: true
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '1%'
      compare << diff_file
      compare.call do |_stdin, _stdout, status|
        expect(status).to be 0
      end
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end
  end

end

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }

  before(:all) do
    Libis::Tools::Config.logger.level = 'off'
  end

  context 'Image Converter' do
    let(:converter) { Libis::Format::Converter::ImageConverter.new }
    let(:diff_file) { File.join(work_dir, 'diff.jpg') }

    it 'converts TIFF to JPEG' do
      src_file = File.join(data_dir, 'test.tif')
      ref_file = File.join(data_dir, 'test.jpg')
      tgt_file = File.join(work_dir, 'test.jpg')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result[:files].first).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '5%'
      compare << diff_file
      compare.call { |_, _, status| expect(status).to be 0 }
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG' do
      src_file = File.join(data_dir, 'test.tif')
      ref_file = File.join(data_dir, 'test.png')
      tgt_file = File.join(work_dir, 'test.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :PNG)
      expect(result[:files].first).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare << diff_file
      compare.call { |_, _, status| expect(status).to be 0 }
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts PDF to TIFF' do
      src_file = File.join(data_dir, 'test.pdf')
      ref_file = File.join(data_dir, 'test.pdf.tif')
      tgt_file = File.join(work_dir, 'test.pdf.tif')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :TIFF)
      expect(result[:files].first).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '100%'
      compare << diff_file
      compare.call { |_, _, status| expect(status).to be 0 }
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG with many options' do
      src_file = File.join(data_dir, 'test.tif')
      ref_file = File.join(data_dir, 'test-options.png')
      tgt_file = File.join(work_dir, 'test-options.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark(text: 'RSPEC', size: 5, opacity: 0.1, rotation: 15, gap: 0.5, composition: 'modulate')
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :PNG, options: { scale: '150%' })
      expect(result[:files].first).to eq tgt_file
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
      src_file = File.join(data_dir, 'multipage.tif')
      ref_file = File.join(data_dir, 'multipage.tif.jp2')
      tgt_file = File.join(work_dir, 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.quiet(true)
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call { |_, _, status| expect(status).to be 0 }
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to JP2' do
      src_file = File.join(data_dir, 'test.tif')
      tgt_file = File.join(work_dir, 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end

    context 'adds watermark' do
      context 'from jpg' do
        it_should_behave_like 'an image watermark', 'jpg', 'jpg'
      end

      context 'from png' do
        it_should_behave_like 'an image watermark', 'png', 'jpg'
      end

      context 'from tiff' do
        it_should_behave_like 'an image watermark', 'tif', 'jpg'
      end

      context 'from JPEG2000' do
        it_should_behave_like 'an image watermark', 'jp2', 'jpg'
      end

      context 'from and to JPEG2000' do
        it_should_behave_like 'an image watermark', 'jp2', 'jp2'
      end

    end
  end

  context 'JP2 Converter', unless: `which "#{Libis::Format::Config[:j2k_cmd]}"` do
    let(:converter) { Libis::Format::Converter::Jp2Converter.new }
    let(:diff_file) { File.join(work_dir, 'diff.jpg') }

    it 'converts TIFF to JP2' do
      src_file = File.join(data_dir, 'test.tif')
      tgt_file = File.join(work_dir, 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end

    it 'converts only first page of multipage TIFF to JP2' do
      src_file = File.join(data_dir, 'multipage.tif')
      ref_file = File.join(data_dir, 'multipage.tif.jp2')
      tgt_file = File.join(work_dir, 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result[:files].first).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call { |_, _, status| expect(status).to be 0 }
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end
  end
end
