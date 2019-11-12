# encoding: utf-8
require 'spec_helper'

describe 'Format Library' do

  before :all do
    ::Libis::Format::YamlLoader.instance.load_formats File.join(File.dirname(__FILE__), 'test_formats.yml')
  end

  it 'should load formats from file' do

    expect(::Libis::Format::Library.get_info :TESTDATA).to eq category: :TESTMEDIUM,
                                                              name: :TESTDATA,
                                                              description: 'Test data format',
                                                              puids: %w'test-fmt/001 spec-fmt/101',
                                                              mimetypes: %w'test/data application/test/data',
                                                              extensions: %w'dat data'
    expect(::Libis::Format::Library.get_info :TESTSPEC).to eq category: :TESTMEDIUM,
                                                              name: :TESTSPEC,
                                                              description: 'Test specification format',
                                                              puids: %w'test-fmt/002 spec-fmt/102',
                                                              mimetypes: %w'test/spec application/test/spec',
                                                              extensions: %w'spc spec'
  end

  it 'should get the category\'s formats' do

    expect(::Libis::Format::Library.get_fields_by :category, :TESTMEDIUM, :name).to eq [:TESTDATA, :TESTSPEC]

  end

  it 'should get the mimetype\'s format name' do

    expect(::Libis::Format::Library.get_field_by(:mimetype, 'test/data', :name)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'application/test/data', :name)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'test/spec', :name)).to eq :TESTSPEC
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'application/test/spec', :name)).to eq :TESTSPEC

  end

  it 'should get the mimetype\'s category' do

    expect(::Libis::Format::Library.get_field_by(:mimetype, 'test/data', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'application/test/data', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'test/spec', :category)).to eq :TESTMEDIUM
    expect(::Libis::Format::Library.get_field_by(:mimetype, 'application/test/spec', :category)).to eq :TESTMEDIUM

  end

  it 'should get the extension\'s format name' do

    expect(::Libis::Format::Library.get_field_by(:extension, 'dat', :name)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:extension, 'data', :name)).to eq :TESTDATA
    expect(::Libis::Format::Library.get_field_by(:extension, 'spc', :name)).to eq :TESTSPEC
    expect(::Libis::Format::Library.get_field_by(:extension, 'spec', :name)).to eq :TESTSPEC

  end

  it 'should check if mimetype is known' do

    expect(::Libis::Format::Library.known?(:mimetype, 'test/data')).to be_truthy
    expect(::Libis::Format::Library.known?(:mimetype, 'test/spec')).to be_truthy

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
                                                                name: :TESTREPORT,
                                                                description: 'Test report format',
                                                                puids: [],
                                                                mimetypes: %w'test/report application/test/report',
                                                                extensions: %w'rep'

  end

  it 'should merge formats from hash' do

    ::Libis::Format::YamlLoader.instance.load_formats TESTMEDIUM: {
        TESTREPORT: {
            EXTENSIONS: 'rpt'
        }
    }

    expect(::Libis::Format::Library.get_info :TESTREPORT).to eq category: :TESTMEDIUM,
                                                                name: :TESTREPORT,
                                                                description: 'Test report format',
                                                                puids: [],
                                                                mimetypes: %w'test/report application/test/report',
                                                                extensions: %w'rep rpt'

  end

end
