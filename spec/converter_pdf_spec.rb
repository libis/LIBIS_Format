# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/pdf_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
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

end
