# frozen_string_literal: true

require 'spec_helper'

require 'libis/format/converter/office_converter'

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }

  before(:all) do
    Libis::Tools::Config.logger.level = 'off'
  end

  context 'Office Converter' do
    let(:converter) { Libis::Format::Converter::OfficeConverter.new }

    it 'converts Word document to PDF' do
      src_file = File.join(data_dir, 'test.doc')
      tgt_file = File.join(work_dir, 'test_doc.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Word 2010 document to PDF' do
      src_file = File.join(data_dir, 'test.docx')
      tgt_file = File.join(work_dir, 'test_docx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts OpenOffice document to PDF' do
      src_file = File.join(data_dir, 'test.odt')
      tgt_file = File.join(work_dir, 'test_odt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts RTF document to PDF' do
      src_file = File.join(data_dir, 'test.rtf')
      tgt_file = File.join(work_dir, 'test_rtf.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts TXT document to PDF' do
      src_file = File.join(data_dir, 'test.txt')
      tgt_file = File.join(work_dir, 'test_txt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel to PDF' do
      src_file = File.join(data_dir, 'test.xls')
      tgt_file = File.join(work_dir, 'test_xls.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel 2011 to PDF' do
      src_file = File.join(data_dir, 'test.xlsx')
      tgt_file = File.join(work_dir, 'test_xlsx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:command][:status]).to eq 0
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end
  end
end
