require_relative "spec_helper"
require 'fileutils'
require 'yaml'
require 'libis/tools/extend/hash'

require "libis/format/converter/email_converter"

require 'byebug'

describe "Converters" do
  let(:repository) { Libis::Format::Converter::Repository }
  let(:work_dir) { File.join(data_dir, "..", "work") }

  before(:all) {
    Libis::Tools::Config.logger.level = "off"
  }

  context "Email Converter" do
    let(:converter) { Libis::Format::Converter::EmailConverter.new }

    it "converts email to PDF" do
      src_file = File.join(data_dir, "email", "test.msg")
      tgt_file = File.join(work_dir, "test_msg.pdf")
      tgt_file_truth = File.join(data_dir, "email", "test_msg.pdf")
      headers_file = File.join(work_dir, "test_msg.headers.xml")
      headers_file_truth = File.join(data_dir, "email", "test_msg.headers.yml")
      attachments_file = File.join(work_dir, "test_msg.pdf.attachments", "1-test simple email.msg.pdf")
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:files].size).to eq 2
      expect(result[:files]).to match_array([tgt_file, attachments_file])
      headers = YAML.load_file(headers_file_truth).symbolize_keys!
      expect(result[:headers]).to include(headers)
      expect(result[:files][1..]).to match_array(headers[:attachments].map{|f| File.join(work_dir,f)})
      FileUtils.rm tgt_file, force: true
      FileUtils.rm headers_file, force: true
      FileUtils.rm attachments_file, force: true
    end
  end
end
