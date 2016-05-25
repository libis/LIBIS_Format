# encoding: utf-8
require 'spec_helper'

describe 'Identfier' do

  dir = File.join File.absolute_path(File.dirname(__FILE__)), 'data'

  before :all do
    ::Libis::Tools::Config.logger.appenders =
        ::Logging::Appenders.string_io('StringIO', layout: ::Libis::Tools::Config.get_log_formatter)
    ::Libis::Tools::Config.logger.level = :all
  end

  let(:logoutput) { ::Libis::Tools::Config.logger.appenders.last.sio }

  it 'should initialize correctly' do
    # expect(Libis::Format::Identifier.fido_formats.size).to be 1
    # expect(File.basename(Libis::Format::Identifier.fido_formats.first)).to eq 'lias_formats.xml'

    expect(Libis::Format::Identifier.xml_validations.size).to be 1
    expect(File.basename Libis::Format::Identifier.xml_validations['archive/ead']).to eq 'ead.xsd'
  end

  it 'should not attempt to identify a directory' do
    expect(Libis::Format::Identifier.get dir).to be_nil
  end

  it 'should not attempt to identify a file that does not exist' do
    expect(Libis::Format::Identifier.get File.join(dir, 'does_not_exist_file')).to be_nil
  end

    # noinspection RubyStringKeysInHashInspection
    {
        'Cevennes2.ppm' => {mimetype: 'image/x‑portable‑pixmap', puid: 'fmt/408'},
        'Cevennes2.bmp' => {mimetype: 'image/bmp', puid: 'fmt/116'},
        'Cevennes2.jp2' => {mimetype: 'image/jp2', puid: 'x-fmt/392'},
        'test.odt' => {mimetype: 'application/vnd.oasis.opendocument.text', puid: 'fmt/291'},
        'test.doc' => {mimetype: 'application/msword', puid: 'fmt/40'},
        'test.docx' => {mimetype: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', puid: 'fmt/412'},
        'test.pdf' => {mimetype: 'application/pdf', puid: 'fmt/18'},
        'test.rtf' => {mimetype: 'application/rtf', puid: 'fmt/45'},
        'test.txt' => {mimetype: 'text/plain', puid: 'x-fmt/111'},
        'test.ods' => {mimetype: 'application/vnd.oasis.opendocument.spreadsheet', puid: 'fmt/295'},
        'test.xls' => {mimetype: 'application/vnd.ms-excel', puid: 'fmt/61'},
        'test.xlsx' => {mimetype: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', puid: 'fmt/214'},
        'test.psd' => {mimetype: 'image/vnd.adobe.photoshop', puid: 'x-fmt/92'},
        'test.bmp' => {mimetype: 'image/bmp', puid: 'fmt/119'},
        'test.tif' => {mimetype: 'image/tiff', puid: 'fmt/353'},
        'test-jpg.tif' => {mimetype: 'image/tiff', puid: 'fmt/353'},
        'test-lzw.tif' => {mimetype: 'image/tiff', puid: 'fmt/353'},
        'test.ps' => {mimetype: 'application/postscript', puid: 'x-fmt/408'},
        'test.png' => {mimetype: 'image/png', puid: 'fmt/11'},
        'test.jpg' => {mimetype: 'image/jpeg', puid: 'fmt/43'},
        'test.gif' => {mimetype: 'image/gif', puid: 'fmt/4'},
        'test.xml' => {mimetype: 'application/xml', puid: 'fmt/101'},
        'test-ead.xml' => {mimetype: 'archive/ead', puid: 'fmt/101'},
        'NikonRaw-CaptureOne.tif' => {mimetype: 'image/tiff', puid: 'x-fmt/387'},
        'NikonRaw-CameraRaw.TIF' => {mimetype: 'image/tiff', puid: 'fmt/202'},
    }.each do |file, result|
      it "should identify test document '#{file}'" do
        expect(::Libis::Format::Identifier.get(File.join(dir,file))).to include result
      end
    end

end
