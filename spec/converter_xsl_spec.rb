require "spec_helper"

require "fileutils"
require "rspec/matchers"
require "equivalent-xml"

require "libis/format/converter/xslt_converter"

describe "Converters" do
  let(:repository) { Libis::Format::Converter::Repository }
  let(:work_dir) { File.join(data_dir, "..", "work") }

  before(:all) {
    Libis::Tools::Config.logger.level = "error"
  }

  if RUBY_PLATFORM != "java"
    context "XSLT Converter" do
      let(:converter) { Libis::Format::Converter::XsltConverter.new }
      let(:dir) { File.join(data_dir, "xml") }

      it "converts XML to EAD" do
        src_file = File.join dir, "134476_raw.XML"
        tgt_file = File.join work_dir, "134476_ead.XML"
        cmp_file = File.join dir, "134476_ead.XML"
        xsl_file = File.join dir, "scope_xmlToEAD_dom.xsl"
        converter.xsl_file xsl_file
        FileUtils.remove tgt_file, force: true
        FileUtils.mkdir_p File.dirname(tgt_file)
        result = converter.convert src_file, tgt_file, :XML
        expect(result[:files].first).to eq tgt_file
        expect(FileUtils.compare_file(tgt_file, cmp_file)).to be_truthy
        FileUtils.rm tgt_file, force: true
      end

      it "converts EAD to XML-FO" do
        src_file = File.join dir, "134476_ead.XML"
        tgt_file = File.join work_dir, "134476_fo.XML"
        cmp_file = File.join dir, "134476_fo.XML"
        xsl_file = File.join dir, "ead2fo_pdf.xsl"
        converter.xsl_file xsl_file
        FileUtils.remove tgt_file, force: true
        FileUtils.mkdir_p File.dirname(tgt_file)
        result = converter.convert src_file, tgt_file, :XML
        expect(result[:files].first).to eq tgt_file
        expect(FileUtils.compare_file(tgt_file, cmp_file)).to be_truthy
        FileUtils.rm tgt_file, force: true
      end
    end
  end
end
