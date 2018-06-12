# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/spreadsheet_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Spreadsheet Converter' do

    let(:converter) {Libis::Format::Converter::SpreadsheetConverter.new}

    it 'converts Excel to ODS' do
      src_file = File.join(file_dir, 'data', 'test.xls')
      tgt_file = File.join(file_dir, 'work', 'test_xls.ods')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :OO_CALC)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel 2011 to ODS' do
      src_file = File.join(file_dir, 'data', 'test.xlsx')
      tgt_file = File.join(file_dir, 'work', 'test_xlsx.ods')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :OO_CALC)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

end
