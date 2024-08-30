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

      it "adds text watermark to #{test} PDF" do
        src_file = File.join(data_dir, "#{test}.pdf")
        tgt_file = File.join(work_dir, "#{test}_wm_text.pdf")
        FileUtils.mkdir_p File.dirname(tgt_file)
        converter.watermark(
          text: 'Test',
          rotation: 90,
          size: 20,
          gap: 5,
          padding: 0.1,
          opacity: 0.6)
        result = converter.convert(src_file, tgt_file, :PDF)
        expect(result[:files].first).to eq tgt_file
        FileUtils.rm tgt_file, force: true
      end

      it "adds image watermark to #{test} PDF" do
        src_file = File.join(data_dir, "#{test}.pdf")
        tgt_file = File.join(work_dir, "#{test}_wm_image.pdf")
        FileUtils.mkdir_p File.dirname(tgt_file)
        converter.watermark(
          image: File.join(data_dir, 'test.jpg'),
          opacity: 0.4)
        result = converter.convert(src_file, tgt_file, :PDF)
        expect(result[:files].first).to eq tgt_file
        FileUtils.rm tgt_file, force: true
      end

      it "adds banner watermark to #{test} PDF" do
        src_file = File.join(data_dir, "#{test}.pdf")
        tgt_file = File.join(work_dir, "#{test}_wm_banner.pdf")
        FileUtils.mkdir_p File.dirname(tgt_file)
        converter.watermark(
          banner: "Test banner: ",
          add_filename: true)
        result = converter.convert(src_file, tgt_file, :PDF)
        expect(result[:files].first).to eq tgt_file
        FileUtils.rm tgt_file, force: true
      end

      (0..4).each do |q|
        it "optimizes #{test} PDF with quality #{q}" do
          src_file = File.join(data_dir, "#{test}.pdf")
          tgt_file = File.join(work_dir, "#{test}_optimized_q#{q}.pdf")
          FileUtils.mkdir_p File.dirname(tgt_file)
          converter.optimize(q)
          result = converter.convert(src_file, tgt_file, :PDF)
          expect(result[:files].first).to eq tgt_file
          FileUtils.rm tgt_file, force: true
        end
      end

    end

    it "selects test PDF fist page" do
      src_file = File.join(data_dir, "test.pdf")
      tgt_file = File.join(work_dir, "test_first_page.pdf")
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.range('1')
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it "sets test PDF metadata" do
      src_file = File.join(data_dir, "test.pdf")
      tgt_file = File.join(work_dir, "test_metadata.pdf")
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.metadata(
        title: 'test title',
        author: 'test author',
        creator: 'test creator',
        keywords: 'test keywords',
        subject: 'test subject'
      )
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result[:files].first).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end
  end
end
