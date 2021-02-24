# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/pdf_converter'
require 'libis/format/converter/pdf_splitter'
require 'libis/format/converter/pdf_assembler'
require 'libis/format/converter/pdf_metadata'
require 'libis/format/converter/pdf_optimizer'
require 'libis/format/converter/pdf_protecter'
require 'libis/format/converter/pdf_selecter'
require 'libis/format/converter/pdf_watermarker_image'
require 'libis/format/converter/pdf_watermarker_text'
require 'libis/format/converter/pdf_watermarker_header'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}

  before(:all) {
    Libis::Tools::Config.logger.level = :WARN
  }

  context 'Pdf Converter' do

    let(:converter) {Libis::Format::Converter::PdfConverter.new}

    it 'converts PDF to PDF/A' do
      src_file = File.join(data_dir, 'test.pdf')
      tgt_file = File.join('', 'tmp', 'test_pdfa.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDFA)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

  context 'Pdf Splitter' do

    let(:converter) {Libis::Format::Converter::PdfSplitter.new}

    it 'splits PDF into PDF per page' do
      src_file = File.join(data_dir, 'test.pdf')
      tgt_file = File.join('', 'tmp', 'test.pdf')
      tgt_files = [
        File.join('', 'tmp', 'test-1.pdf'),
        File.join('', 'tmp', 'test-2.pdf')
      ]
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_files
      FileUtils.rm tgt_files[0], force: true
      FileUtils.rm tgt_files[1], force: true
    end

  end

  context 'Pdf Assembler' do

    let(:converter) {Libis::Format::Converter::PdfAssembler.new}

    it 'combines multiple PDFs into a single PDF' do
      src_files = [
        File.join(data_dir, 'test-1.pdf'),
        File.join(data_dir, 'test-2.pdf')
      ]
      tgt_file = File.join('', 'tmp', 'test.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_files, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

end
