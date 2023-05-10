# encoding: utf-8
require 'spec_helper'

require 'fileutils'
require 'rspec/matchers'

require 'libis/format/converter/fop_pdf_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:work_dir) { File.join(data_dir, "..", "work") }

  before(:all) {
    Libis::Tools::Config.logger.level = 'error'
  }

  context 'Apache FOP-PDF Converter' do

    let(:converter) {Libis::Format::Converter::FopPdfConverter.new}
    let(:dir) {File.join(data_dir, 'xml')}

    it 'converts XML-FO to PDF' do
      if File.exist?(Libis::Format::Config[:fop_jar])
        src_file = File.join dir, '134476_fo.XML'
        tgt_file = File.join work_dir, '134476_ead.pdf'
        cmp_file = File.join dir, '134476_ead.pdf'
        FileUtils.remove tgt_file, force: true
        FileUtils.mkdir_p File.dirname(tgt_file)
        result = converter.convert src_file, tgt_file, :PDF
        expect(result[:files].first).to eq tgt_file
        FileUtils.rm tgt_file, force: true
      end
    end

  end

end
