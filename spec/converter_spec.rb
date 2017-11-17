# encoding: utf-8
require 'spec_helper'

require 'libis/format/converter/image_converter'
require 'libis/format/converter/pdf_converter'
require 'libis/format/converter/office_converter'
require 'libis/format/converter/jp2_converter'
require 'libis/format/converter/audio_converter'
require 'libis/format/converter/video_converter'

describe 'Converters' do

  let(:repository) {Libis::Format::Converter::Repository}
  let(:file_dir) {File.dirname(__FILE__)}

  before(:all) {
    Libis::Tools::Config.logger.level = 'off'
  }

  context 'Repository' do

    it 'loads all converters' do
      expect(repository.get_converters.size).to eq 6
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::ImageConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::OfficeConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::PdfConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::Jp2Converter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::AudioConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::VideoConverter'
    end

    it 'creates simple converter chain' do
      chain = repository.get_converter_chain(:TIFF, :PDF)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [{converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF}]
    end

    it 'creates complex chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF},
                                          {converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA},
                                      ]
    end

    it 'creates converter chain with options' do
      chain = repository.get_converter_chain(:TIFF, :PDF, {watermark: {}})
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF, operations: [{method: :watermark, argument: {}}]}
                                      ]
    end

    it 'perfers operations to the end of the chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA, {watermark: {}})
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
                                          {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF},
                                          {converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA, operations: [{method: :watermark, argument: {}}]}
                                      ]
    end

    context 'create chain for TIFF to JP2' do

      it 'without operators' do
        chain = repository.get_converter_chain(:TIFF, :JP2)
        expect(chain).to_not be nil
        expect(chain.to_array.size).to eq 1
        expect(chain.to_array).to match [
                                            {converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :JP2}
                                        ]
      end

      it 'with force operator' do
        chain = repository.get_converter_chain(:TIFF, :JP2, {lossless: true})
        expect(chain).to_not be nil
        expect(chain.to_array.size).to eq 1
        expect(chain.to_array).to match [
                                            {converter: Libis::Format::Converter::Jp2Converter, input: :TIFF, output: :JP2, operations: [{method: :lossless, argument: true}]}
                                        ]
      end

    end

  end

  context 'Image Converter' do

    let(:converter) {Libis::Format::Converter::ImageConverter.new}
    let(:diff_file) {File.join('', 'tmp', 'diff.jpg')}

    it 'converts TIFF to JPEG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.jpg')
      tgt_file = File.join('', 'tmp', 'test.jpg')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JPG)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '1%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test.png')
      tgt_file = File.join('', 'tmp', 'test.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :PNG)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts PDF to TIFF' do
      src_file = File.join(file_dir, 'data', 'test.pdf')
      ref_file = File.join(file_dir, 'data', 'test.pdf.tif')
      tgt_file = File.join('', 'tmp', 'test.pdf.tif')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :TIFF)
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '100%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to PNG with many options' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      ref_file = File.join(file_dir, 'data', 'test-options.png')
      tgt_file = File.join('', 'tmp', 'test-options.png')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.watermark(text: 'RSPEC', size: 5, opacity: 0.1, rotation: 15, gap: 0.5, composition: 'modulate')
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :PNG, options: {scale: '150%'})
      expect(result).to eq tgt_file
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'AE'
      compare.fuzz << '100%'
      compare << diff_file
      compare.call do |_stdin, _stdout, status|
        expect(status).to be 0
      end
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts only first page of multipage TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'multipage.tif')
      ref_file = File.join(file_dir, 'data', 'multipage.tif.jp2')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      converter.quiet(true)
      converter.page(0)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

    it 'converts TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      converter.delete_date
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end


  end

  context 'JP2 Converter', if: File.exists?(Libis::Format::Config[:j2kdriver]) do

    let(:converter) {Libis::Format::Converter::Jp2Converter.new}
    let(:diff_file) {File.join('', 'tmp', 'diff.jpg')}

    it 'converts TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'test.tif')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      FileUtils.rm tgt_file, force: true
    end

    it 'converts only first page of multipage TIFF to JP2' do
      src_file = File.join(file_dir, 'data', 'multipage.tif')
      ref_file = File.join(file_dir, 'data', 'multipage.tif.jp2')
      tgt_file = File.join('', 'tmp', 'test.jp2')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :JP2)
      expect(result).to eq tgt_file
      expect(File.exist?(tgt_file)).to be_truthy
      compare = MiniMagick::Tool::Compare.new
      compare << ref_file << tgt_file
      compare.metric << 'MAE'
      compare.fuzz << '10%'
      compare << diff_file
      compare.call {|_, _, status| expect(status).to be 0}
      FileUtils.rm tgt_file, force: true
      FileUtils.rm diff_file, force: true
    end

  end

  context 'Pdf Converter', if: File.exists?(Libis::Format::Config[:ghostscript_path]) do

    let(:converter) {Libis::Format::Converter::PdfConverter.new}

    it 'converts PDF to PDF/A' do
      src_file = File.join(file_dir, 'data', 'test.pdf')
      tgt_file = File.join('', 'tmp', 'test_pdfa.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDFA)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

  context 'Office Converter' do

    let(:converter) {Libis::Format::Converter::OfficeConverter.new}

    it 'converts Word document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.doc')
      tgt_file = File.join(file_dir, 'work', 'test_doc.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Word 2010 document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.docx')
      tgt_file = File.join(file_dir, 'work', 'test_docx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts OpenOffice document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.odt')
      tgt_file = File.join(file_dir, 'work', 'test_odt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts RTF document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.rtf')
      tgt_file = File.join(file_dir, 'work', 'test_rtf.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts TXT document to PDF' do
      src_file = File.join(file_dir, 'data', 'test.txt')
      tgt_file = File.join(file_dir, 'work', 'test_txt.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel to PDF' do
      src_file = File.join(file_dir, 'data', 'test.xls')
      tgt_file = File.join(file_dir, 'work', 'test_xls.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

    it 'converts Excel 2011 to PDF' do
      src_file = File.join(file_dir, 'data', 'test.xlsx')
      tgt_file = File.join(file_dir, 'work', 'test_xlsx.pdf')
      FileUtils.mkdir_p File.dirname(tgt_file)
      result = converter.convert(src_file, tgt_file, :PDF)
      expect(result).to eq tgt_file
      FileUtils.rm tgt_file, force: true
    end

  end

  context 'Audio Converter' do

    let(:converter) {Libis::Format::Converter::AudioConverter.new}
    extensions = %w'aac aiff au flac m4a mka mp3 ra voc wav wma'
    confidence = {
        aac: 0.86,
        aiff: 0.99,
        au: 0.99,
        flac: 0.99,
        m4a: 0.93,
        mka: 0.94,
        mp3: 0.95,
        ra: 0.92,
        voc: 0.99,
        wav: 0.99,
        wma: 0.9
    }
    targets = %w'mp3 flac wav'
    sources = %w'carlin_disappointed greensleeves king_nonviolence top_gun_secret'
    quality = {
        carlin_disappointed: 1.0,
        greensleeves: 0.95,
        king_nonviolence: 1.0,
        top_gun_secret: 0.95
    }

    let(:data_dir) {File.join(file_dir, 'data', 'audio')}

    context 'converts' do
      sources.each do |source|
        extensions.each do |ext|
          next unless (File.exists?(File.join(File.dirname(__FILE__), 'data', 'audio', "#{source}.#{ext}")))
          (targets - [ext]).each do |tgt|
            it "#{source} #{ext} to #{tgt}" do
              src_file = File.join(data_dir, "#{source}.#{ext}")
              ref_file = File.join(data_dir, "#{source}.#{tgt}")
              tgt_file = File.join('', 'tmp', "test.#{source}.#{ext}.#{tgt}")
              FileUtils.remove tgt_file, force: true
              FileUtils.mkdir_p File.dirname(tgt_file)
              result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
              expect(result).to eq tgt_file
              expect(result).to sound_like ref_file, confidence[ext.to_sym] * quality[source.to_sym], 11025, 1
              FileUtils.remove tgt_file, force: true
            end
          end
        end
      end
    end

  end

  context 'Video Converter' do

    let(:converter) {Libis::Format::Converter::VideoConverter.new}
    extensions = %w'3gp avi flv mkv mov mp4 mpg swf webm wmv'
    targets = %w'avi flv mkv mov mp4 swf webm wmv gif'
    # noinspection RubyLiteralArrayInspection
    sources = [
        'SampleVideo_176x144_2mb',
        'SampleVideo_320x240_2mb',
        'SampleVideo_360x240_2mb',
        'SampleVideo_1080x720_2mb'
    ]
    bad_converts = [
    ]
    let(:data_dir) {File.join(file_dir, 'data', 'video')}


    context 'converts' do
      sources.each do |source|
        context source do
          extensions.each do |ext|
            next unless (File.exists?(File.join(File.dirname(__FILE__), 'data', 'video', "#{source}.#{ext}")))
            (targets - [ext]).each do |tgt|
              next if bad_converts.include? [ext, tgt]
              it "#{ext} to #{tgt}" do
                src_file = File.join(data_dir, "#{source}.#{ext}")
                tgt_file = File.join('', 'tmp', "test.#{source}.#{ext}.#{tgt}")
                FileUtils.remove tgt_file, force: true
                FileUtils.mkdir_p File.dirname(tgt_file)
                converter.audio_channels(2) if %w'swf wmv'.include?(tgt)
                # converter.constant_rate_factor(24) if %w'swf wmv'.include?(tgt)
                converter.sampling_freq(44100) if tgt == 'swf'
                if tgt == 'gif'
                  converter.start(1)
                  converter.duration(3)
                  converter.scale('100x100')
                end
                result = converter.convert(src_file, tgt_file, tgt.upcase.to_sym)
                expect(result).to eq tgt_file
                expect(File.size(result)).to be > 2000
                FileUtils.remove tgt_file, force: true
              end
            end
          end
        end
      end
    end

  end

end
