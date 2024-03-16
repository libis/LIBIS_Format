# frozen_string_literal: true

require 'spec_helper'

require 'libis/format/converter/pdf_converter'

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }

  before(:all) do
    Libis::Tools::Config.logger.level = :WARN
  end

  context 'Pdf Converter' do
    let(:converter) { Libis::Format::Converter::PdfConverter.new }

    %w[test test2 test3].each do |test|
      it "converts #{test} PDF to PDF/A" do
        src_file = File.join(data_dir, "#{test}.pdf")
        tgt_file = File.join(work_dir, "#{test}_pdfa.pdf")
        FileUtils.mkdir_p File.dirname(tgt_file)
        result = converter.convert(src_file, tgt_file, :PDFA)
        expect(result[:files].first).to eq tgt_file
        FileUtils.rm tgt_file, force: true
      end
    end
  end
end
