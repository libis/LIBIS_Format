# encoding: utf-8
require 'spec_helper'

describe 'Format Library' do

  before :all do
    ::Libis::Format::YamlLoader.instance.load_formats File.join(File.dirname(__FILE__), 'test_formats.yml')
  end

  it 'should load formats from file' do

    expect(::Libis::Format::Library.get_info :TESTDATA).to eq category: :TESTMEDIUM,
                                                              format: :TESTDATA,
                                                              description: 'Test data format',
                                                              puids: %w'test-fmt/001 spec-fmt/101',
                                                              mime_types: %w'test/data application/test/data',
                                                              extensions: %w'dat data'
    expect(::Libis::Format::Library.get_info :TESTSPEC).to eq category: :TESTMEDIUM,
                                                              format: :TESTSPEC,
                                                              description: 'Test specification format',
                                                              puids: %w'test-fmt/002 spec-fmt/102',
                                                              mime_types: %w'test/spec application/test/spec',
                                                              extensions: %w'spc spec'
  end

  it 'should get the category\'s formats' do

    expect(::Libis::Format::Library.get_fields_by :category, :TESTMEDIUM, :format).to eq [:TESTDATA, :TESTSPEC]

  end

  it 'should get the mimetype\'s format name' do

    expect(::Libis::Format::Library.get_field_by(:mime_type, 'test/data', :format)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'application/test/data', :format)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'test/spec', :format)).to eq :TESTSPEC
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'application/test/spec', :format)).to eq :TESTSPEC

  end

  it 'should get the mimetype\'s category' do

    expect(::Libis::Format::Library.get_field_by(:mime_type, 'test/data', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'application/test/data', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'test/spec', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mime_type, 'application/test/spec', :category)).to eq :TESTMEDIUM

  end

  it 'should get the extension\'s format name' do

    expect(::Libis::Format::Library.get_field_by(:extension, 'dat', :format)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:extension, 'data', :format)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:extension, 'spc', :format)).to eq :TESTSPEC
    expect(::Libis::Format::Library.get_field_by(:extension, 'spec', :format)).to eq :TESTSPEC

  end

  it 'should check if mimetype is known' do

    expect(::Libis::Format::Library.known?(:mime_type, 'test/data')).to be_truthy
    expect(::Libis::Format::Library.known?(:mime_type, 'test/spec')).to be_truthy

  end

  it 'should load formats from hash' do

    ::Libis::Format::YamlLoader.instance.load_formats TESTMEDIUM: {
        TESTREPORT: {
            NAME: 'Test report format',
            MIME: 'test/report application/test/report',
            EXTENSIONS: 'rep'
        }
    }

    expect(::Libis::Format::Library.get_info :TESTREPORT).to eq category: :TESTMEDIUM,
                                                                format: :TESTREPORT,
                                                                description: 'Test report format',
                                                                puids: [],
                                                                mime_types: %w'test/report application/test/report',
                                                                extensions: %w'rep'

  end

  it 'should merge formats from hash' do

    ::Libis::Format::YamlLoader.instance.load_formats TESTMEDIUM: {
        TESTREPORT: {
            EXTENSIONS: 'rpt'
        }
    }

    expect(::Libis::Format::Library.get_info :TESTREPORT).to eq category: :TESTMEDIUM,
                                                                format: :TESTREPORT,
                                                                description: 'Test report format',
                                                                puids: [],
                                                                mime_types: %w'test/report application/test/report',
                                                                extensions: %w'rep rpt'

  end

end
