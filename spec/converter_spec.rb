# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/image_converter'
require 'libis/format/converter/pdf_converter'
require 'libis/format/converter/office_converter'

RSpec::Matchers.define(:be_same_file_as) do |exected_file_path|
  match do |actual_file_path|
    expect(md5_hash(actual_file_path)).to eq md5_hash(exected_file_path)
  end

  def md5_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path))
  end
end

describe 'Converters' do

  let(:repository) { Libis::Format::Converter::Repository }
  let(:file_dir) { File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = :WARN
  }

  context 'Repository' do

    it 'loads all converters' do
      expect(repository.get_converters.size).to eq 3
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::ImageConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::OfficeConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::PdfConverter'
    end

    it 'creates simple converter chain' do
      chain = repository.get_converter_chain(:TIFF, :PDF)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [{converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF}]
    end

    it 'creates complex chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF},
                                          {converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA},
                                      ]
    end

    it 'creates converter chain with options' do
      chain = repository.get_converter_chain(:TIFF, :PDF, {watermark: {}})
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF, operations: [{method: :watermark, argument: {}}]}
                                      ]
    end

    it 'perfers operations to the end of the chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA, {watermark: {}})
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF},
                                          {converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA, operations: [{method: :watermark, argument: {}}]}
                                      ]
    end

  end

  context 'Image Converter' do

    let(:converter) { Libis::Format::Converter::ImageConverter.new }

    it 'converts TIFF to JPEG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.jpg')
      tgt_file = File.join('', 'tmp', 'test.jpg')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result).to eq tgt_file
      expect(tgt_file).to be_same_file_as ref_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts TIFF to PNG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.png')
      tgt_file = File.join('', 'tmp', 'test.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PNG)
      expect(result).to eq tgt_file
      expect(tgt_file).to be_same_file_as ref_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts PDF to TIFF' do
      src_file = File.join(file_dir, 'data', 'test.pdf')
      ref_file = File.join(file_dir, 'data', 'test.pdf.tif')
      tgt_file = File.join('', 'tmp', 'test.pdf.tif')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :TIFF)
      expect(result).to eq tgt_file
      expect(tgt_file).to be_same_file_as ref_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts TIFF to JPEG with many options' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test-options.jpg')
      tgt_file = File.join('', 'tmp', 'test-options.jpg')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark(text: 'RSPEC', size: 5, opacity: 0.1, rotation: 15, gap: 0.5, composition: 'modulate')
      result = converter.convert(src_file, tgt_file, :JPG, options: {scale: '150%', quality: '70%'})
      expect(result).to eq tgt_file
      expect(tgt_file).to be_same_file_as ref_file
      FileUtils.rm tgt_file, force: true
    end

  end

  context 'Pdf Converter' do

    let(:converter) { Libis::Format::Converter::PdfConverter.new }

    it 'converts PDF to PDF/A' do
      src_file = File.join(file_dir, 'data', 'test.pdf')
      tgt_file = File.join('', 'tmp', 'test_pdfa.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDFA)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

  context 'Office Converter' do

    let(:converter) { Libis::Format::Converter::OfficeConverter.new }

    it 'converts Word document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.doc')
      tgt_file = File.join(file_dir, 'work', 'test_doc.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Word 2010 document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.docx')
      tgt_file = File.join(file_dir, 'work', 'test_docx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts OpenOffice document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.odt')
      tgt_file = File.join(file_dir, 'work', 'test_odt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts RTF document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.rtf')
      tgt_file = File.join(file_dir, 'work', 'test_rtf.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts TXT document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.txt')
      tgt_file = File.join(file_dir, 'work', 'test_txt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel to PDF' do
      src_file = File.join(file_dir, 'data', 'test.xls')
      tgt_file = File.join(file_dir, 'work', 'test_xls.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel 2011 to PDF' do
      src_file = File.join(file_dir, 'data', 'test.xlsx')
      tgt_file = File.join(file_dir, 'work', 'test_xlsx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

end
