# encoding: utf-8
require 'spec_helper'

require 'fileutils'
require 'rspec/matchers'
require 'equivalent-xml'

require 'libis/format/converter/xslt_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'error'
  }

  context 'XSLT Converter' do

    let(:converter) {Libis::Format::Converter::XsltConverter.new}
    let(:data_dir) {File.join(file_dir, 'data', 'xml')}

    it 'converts XML to EAD' do
      src_file = File.join data_dir, '134476_raw.XML'
      tgt_file = File.join '', 'tmp', '134476_ead.XML'
      cmp_file = File.join data_dir, '134476_ead.XML'
      xsl_file = File.join data_dir, 'scope_xmlToEAD_dom.xsl'
      converter.xsl_file xsl_file
      FileUtils.remove tgt_file, force: true
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert src_file, tgt_file, :XML
      expect(result).to eq tgt_file
      tgt = Nokogiri::XML(File.read(tgt_file))
      cmp = Nokogiri::XML(File.read(cmp_file))
      expect(tgt.root).to be_equivalent_to(cmp.root).respecting_element_order
    end

    it 'converts EAD to XML-FO' do
      src_file = File.join data_dir, '134476_ead.XML'
      tgt_file = File.join '', 'tmp', '134476_fo.XML'
      cmp_file = File.join data_dir, '134476_fo.XML'
      xsl_file = File.join data_dir, 'ead2fo_pdf.xsl'
      converter.xsl_file xsl_file
      FileUtils.remove tgt_file, force: true
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert src_file, tgt_file, :XML
      expect(result).to eq tgt_file
      tgt = Nokogiri::XML(File.read(tgt_file))
      cmp = Nokogiri::XML(File.read(cmp_file))
      expect(tgt.root).to be_equivalent_to(cmp.root).respecting_element_order
    end

  end

end
