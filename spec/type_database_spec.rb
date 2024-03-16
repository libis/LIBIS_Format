# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe 'Type Databse' do
  before :all do
    ::Libis::Format::TypeDatabaseImpl.instance.load_types File.join(File.dirname(__FILE__), 'test_types.yml')
  end

  it 'should load types from file' do
    expect(::Libis::Format::TypeDatabase.typeinfo(:TESTDATA)).to eq GROUP: :TESTMEDIUM,
                                                                    TYPE: :TESTDATA,
                                                                    NAME: 'Test data format',
                                                                    PUID: %w[test-fmt/001 spec-fmt/101],
                                                                    MIME: %w[test/data application/test/data],
                                                                    EXTENSIONS: %w[dat data]
    expect(::Libis::Format::TypeDatabase.typeinfo(:TESTSPEC)).to eq GROUP: :TESTMEDIUM,
                                                                    TYPE: :TESTSPEC,
                                                                    NAME: 'Test specification format',
                                                                    PUID: %w[test-fmt/002 spec-fmt/102],
                                                                    MIME: %w[test/spec application/test/spec],
                                                                    EXTENSIONS: %w[spc spec]
  end

  it 'should get the type\'s group' do
    expect(::Libis::Format::TypeDatabase.type_group(:TESTDATA)).to eq :TESTMEDIUM
    expect(::Libis::Format::TypeDatabase.type_group(:TESTSPEC)).to eq :TESTMEDIUM
  end

  it 'should get the type\'s puids' do
    expect(::Libis::Format::TypeDatabase.type_puids(:TESTDATA)).to eq %w[test-fmt/001 spec-fmt/101]
    expect(::Libis::Format::TypeDatabase.type_puids(:TESTSPEC)).to eq %w[test-fmt/002 spec-fmt/102]
  end

  it 'should get the type\'s mimetypes' do
    expect(::Libis::Format::TypeDatabase.type_mimetypes(:TESTDATA)).to eq %w[test/data application/test/data]
    expect(::Libis::Format::TypeDatabase.type_mimetypes(:TESTSPEC)).to eq %w[test/spec application/test/spec]
  end

  it 'should get the type\'s extensions' do
    expect(::Libis::Format::TypeDatabase.type_extentions(:TESTDATA)).to eq %w[dat data]
    expect(::Libis::Format::TypeDatabase.type_extentions(:TESTSPEC)).to eq %w[spc spec]
  end

  it 'should get the group\'s types' do
    expect(::Libis::Format::TypeDatabase.group_types(:TESTMEDIUM)).to eq %i[TESTDATA TESTSPEC]
  end

  it 'should get the mimetype\'s types' do
    expect(::Libis::Format::TypeDatabase.mime_types('test/data')).to eq [:TESTDATA]
    expect(::Libis::Format::TypeDatabase.mime_types('application/test/data')).to eq [:TESTDATA]
    expect(::Libis::Format::TypeDatabase.mime_types('test/spec')).to eq [:TESTSPEC]
    expect(::Libis::Format::TypeDatabase.mime_types('application/test/spec')).to eq [:TESTSPEC]
  end

  it 'should get the mimetype\'s groups' do
    expect(::Libis::Format::TypeDatabase.mime_groups('test/data')).to eq [:TESTMEDIUM]
    expect(::Libis::Format::TypeDatabase.mime_groups('application/test/data')).to eq [:TESTMEDIUM]
    expect(::Libis::Format::TypeDatabase.mime_groups('test/spec')).to eq [:TESTMEDIUM]
    expect(::Libis::Format::TypeDatabase.mime_groups('application/test/spec')).to eq [:TESTMEDIUM]
  end

  it 'should get the extension\'s types' do
    expect(::Libis::Format::TypeDatabase.ext_types('dat')).to eq [:TESTDATA]
    expect(::Libis::Format::TypeDatabase.ext_types('data')).to eq [:TESTDATA]
    expect(::Libis::Format::TypeDatabase.ext_types('spc')).to eq [:TESTSPEC]
    expect(::Libis::Format::TypeDatabase.ext_types('spec')).to eq [:TESTSPEC]
  end

  it 'should check if mimetype is known' do
    expect(::Libis::Format::TypeDatabase.known_mime?('test/data')).to be_truthy
    expect(::Libis::Format::TypeDatabase.known_mime?('test/spec')).to be_truthy
  end

  it 'should load types from hash' do
    ::Libis::Format::TypeDatabaseImpl.instance.load_types TESTMEDIUM: {
      TESTREPORT: {
        NAME: 'Test report format',
        MIME: 'test/report application/test/report',
        EXTENSIONS: 'rep'
      }
    }

    expect(::Libis::Format::TypeDatabase.typeinfo(:TESTREPORT)).to eq GROUP: :TESTMEDIUM,
                                                                      TYPE: :TESTREPORT,
                                                                      NAME: 'Test report format',
                                                                      MIME: %w[test/report application/test/report],
                                                                      EXTENSIONS: %w[rep]
  end

  it 'should merge types from hash' do
    ::Libis::Format::TypeDatabaseImpl.instance.load_types TESTMEDIUM: {
      TESTREPORT: {
        EXTENSIONS: 'rpt'
      }
    }

    expect(::Libis::Format::TypeDatabase.typeinfo(:TESTREPORT)).to eq GROUP: :TESTMEDIUM,
                                                                      TYPE: :TESTREPORT,
                                                                      NAME: 'Test report format',
                                                                      MIME: %w[test/report application/test/report],
                                                                      EXTENSIONS: %w[rep rpt]

    ::Libis::Format::TypeDatabaseImpl.instance.load_types({ TESTMEDIUM: {
                                                            TESTREPORT: {
                                                              EXTENSIONS: 'report'
                                                            }
                                                          } }, false)

    expect(::Libis::Format::TypeDatabase.typeinfo(:TESTREPORT)).to eq GROUP: :TESTMEDIUM,
                                                                      TYPE: :TESTREPORT,
                                                                      NAME: 'Test report format',
                                                                      MIME: %w[test/report application/test/report],
                                                                      EXTENSIONS: %w[report rep rpt]
  end

  it 'should export type to CSV' do
    csv = File.join(work_dir, 'test_types.csv')
    expected_csv = File.join(__dir__, 'test_types.csv')
    ::Libis::Format::TypeDatabase.export_csv(csv, write_headers: true)
    expect(FileUtils.compare_file(csv, expected_csv)).to be_truthy
  end

  it 'should export type to TSV' do
    tsv = File.join(work_dir, 'test_types.tsv')
    expected_tsv = File.join(__dir__, 'test_types.tsv')
    ::Libis::Format::TypeDatabase.export_csv(tsv, write_headers: true, col_sep: "\t")
    expect(FileUtils.compare_file(tsv, expected_tsv)).to be_truthy
  end
end
