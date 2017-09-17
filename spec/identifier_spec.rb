# encoding: utf-8
require 'spec_helper'
require 'libis/format/identifier'
require 'awesome_print'

# noinspection RubyStringKeysInHashInspection
formatlist =
    {
        'Cevennes2.ppm' => {mimetype: 'image/x-portable-pixmap', puid: 'fmt/408'},
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
        'test.xml' => {mimetype: 'text/xml', puid: 'fmt/101'},
        'test-ead.xml' => {mimetype: 'archive/ead', puid: 'fmt/101'},
        'NikonRaw-CaptureOne.tif' => {mimetype: 'image/tiff', puid: 'x-fmt/387'},
        'NikonRaw-CameraRaw.TIF' => {mimetype: 'image/tiff', puid: 'fmt/353'},
    }

# noinspection RubyStringKeysInHashInspection
fidolist =
    {
        'Cevennes2.ppm' => {mimetype: 'image/x-portable-pixmap', puid: 'fmt/408'},
        'Cevennes2.bmp' => {mimetype: 'image/bmp', puid: 'fmt/116'},
        'Cevennes2.jp2' => {mimetype: 'image/jp2', puid: 'x-fmt/392'},
        'test.odt' => {mimetype: 'application/vnd.oasis.opendocument.text', puid: 'fmt/290'},
        'test.doc' => {mimetype: nil, puid: 'fmt/111'},
        'test.docx' => {mimetype: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', puid: 'fmt/412'},
        'test.pdf' => {mimetype: 'application/pdf', puid: 'fmt/18'},
        'test.rtf' => {mimetype: 'application/rtf', puid: 'fmt/45'},
        'test.txt' => {mimetype: 'text/plain', puid: 'x-fmt/111'},
        'test.ods' => {mimetype: nil, puid: 'fmt/294'},
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
        'test.xml' => {mimetype: 'text/xml', puid: 'fmt/101'},
        'test-ead.xml' => {mimetype: 'text/xml', puid: 'fmt/101'},
        'NikonRaw-CaptureOne.tif' => {mimetype: 'image/tiff', puid: 'fmt/353'},
        'NikonRaw-CameraRaw.TIF' => {mimetype: 'image/tiff', puid: 'fmt/353'},
    }

describe 'Identfier' do

  dir = File.join File.absolute_path(File.dirname(__FILE__)), 'data'

  let (:identifier) { ::Libis::Format::Identifier }

  before :all do
    ::Libis::Tools::Config.logger.appenders =
        ::Logging::Appenders.string_io('StringIO', layout: ::Libis::Tools::Config.get_log_formatter)
    ::Libis::Tools::Config.logger.level = :all
    ::Libis::Format::Config[:droid_path] = '/opt/droid/droid.sh'
    ::Libis::Format::Config[:fido_path] = '/usr/local/bin/fido'
  end

  let(:logoutput) {::Libis::Tools::Config.logger.appenders.last.sio}

  it 'should initialize correctly' do
    expect(identifier.xml_validations.size).to be 1
    expect(File.basename identifier.xml_validations['archive/ead']).to eq 'ead.xsd'
  end

  # noinspection RubyResolve
  it 'should not attempt to identify a non-existing file or directory' do
    result = identifier.get (File.join(dir, 'abcdef'))
    expect(result[:output]).to be_empty
    expect(result[:formats]).to be_empty
    expect(result[:messages]).not_to be_empty
    expect(result[:messages].all? do |x|
      x[0] == :error &&
          x[1] =~ /^Error running (Droid|Fido|File): IdentificationTool: file argument should be a path to an existing file or directory or a list of those/
    end).to be_truthy
  end

  it 'should identify all files in a folder at once' do
    result = identifier.get (dir)
    expect(result[:formats].size).to be >= formatlist.size
    formatlist.each do |file, format|
      expect(result[:formats][File.join(dir, file)]).to include format
    end
  end

  it 'should identify all files in a list at once' do
    filelist = fidolist.keys.map {|file| File.join(dir, file)}
    result = identifier.get (filelist)
    expect(result[:formats].size).to be >= formatlist.size
    formatlist.each do |file, format|
      expect(result[:formats][File.join(dir, file)]).to include format
    end
  end

  context 'individual files' do

    formatlist.each do |file, format|
      it "should identify test document '#{file}'" do
        result = identifier.get (File.join(dir, file))
        expect(result[:formats].size).to be 1
        expect(result[:formats][File.join(dir, file)]).to include format
      end
    end

  end

  context 'Fido' do

    # expect(identifier.fido_formats.size).to be 1
    # expect(File.basename(identifier.fido_formats.first)).to eq 'lias_formats.xml'
    it 'should identify list of test documents' do
      filelist = formatlist.keys.map {|file| File.join(dir, file)}
      fido_result = ::Libis::Format::Fido.instance.run_list(filelist)
      filelist.each do |filename|
        result = fido_result[filename]
        result = result[0] if result
        # noinspection RubyResolve
        expect(result).to include fidolist[File.basename(filename)]
      end
    end

    it 'should identify dir of test documents' do
      filelist = fidolist.keys.map {|file| File.join(dir, file)}
      fido_result = ::Libis::Format::Fido.instance.run_dir(dir)
      filelist.each do |filename|
        result = fido_result[filename]
        result = result[0] if result
        # noinspection RubyResolve
        expect(result).to include fidolist[File.basename(filename)]
      end
    end

  end

end
