# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/office_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Office Converter' do

    let(:converter) {Libis::Format::Converter::OfficeConverter.new}

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
