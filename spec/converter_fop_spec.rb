# encoding: utf-8
require 'spec_helper'

require 'fileutils'
require 'rspec/matchers'

require 'libis/format/converter/fop_pdf_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'error'
  }

  context 'Apache FOP-PDF Converter' do

    let(:converter) {Libis::Format::Converter::FopPdfConverter.new}
    let(:data_dir) {File.join(file_dir, 'data', 'xml')}

    it 'converts XML-FO to PDF' do
      if File.exist?(Libis::Format::Config[:fop_jar])
        src_file = File.join data_dir, '134476_fo.XML'
        tgt_file = File.join '', 'tmp', '134476_ead.pdf'
        cmp_file = File.join data_dir, '134476_ead.pdf'
        FileUtils.remove tgt_file, force: true
        FileUtils.mkdir_p File.dirname(tgt_file)
        result = converter.convert src_file, tgt_file, :PDF
        expect(result).to eq tgt_file
      end
    end

  end

end
