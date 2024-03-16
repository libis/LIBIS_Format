# frozen_string_literal: true

require 'spec_helper'

describe 'Converters' do
  let(:repository) { Libis::Format::Converter::Repository }

  before(:all) do
    Libis::Tools::Config.logger.level = 'off'
  end

  context 'Repository' do
    it 'loads all converters' do
      expect(repository.get_converters.size).to eq 10
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::ImageConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::OfficeConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::SpreadsheetConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::PdfConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::Jp2Converter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::AudioConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::VideoConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::XsltConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::FopPdfConverter'
      # noinspection RubyResolve
      expect(repository.get_converters.map(&:to_s)).to include 'Libis::Format::Converter::EmailConverter'
    end

    it 'creates simple converter chain' do
      chain = repository.get_converter_chain(:TIFF, :PDF)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [{ converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF }]
    end

    it 'creates complex chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA)
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
        { converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF },
        { converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA }
      ]
    end

    it 'creates converter chain with options' do
      chain = repository.get_converter_chain(:TIFF, :PDF, { watermark: {} })
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 1
      expect(chain.to_array).to match [
        { converter: Libis::Format::Converter::ImageConverter,
          input: :TIFF,
          output: :PDF,
          operations: [{ method: :watermark, argument: {} }] }
      ]
    end

    it 'perfers operations to the end of the chain' do
      chain = repository.get_converter_chain(:TIFF, :PDFA, { watermark: {} })
      expect(chain).to_not be nil
      expect(chain.to_array.size).to eq 2
      expect(chain.to_array).to match [
        { converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :PDF },
        { converter: Libis::Format::Converter::PdfConverter, input: :PDF, output: :PDFA,
          operations: [{ method: :watermark, argument: {} }] }
      ]
    end

    context 'create chain for TIFF to JP2' do
      it 'without operators' do
        chain = repository.get_converter_chain(:TIFF, :JP2)
        expect(chain).to_not be nil
        expect(chain.to_array.size).to eq 1
        expect(chain.to_array).to match [
          { converter: Libis::Format::Converter::ImageConverter, input: :TIFF, output: :JP2 }
        ]
      end

      it 'with force operator' do
        chain = repository.get_converter_chain(:TIFF, :JP2, { lossless: true })
        expect(chain).to_not be nil
        expect(chain.to_array.size).to eq 1
        expect(chain.to_array).to match [
          { converter: Libis::Format::Converter::Jp2Converter, input: :TIFF, output: :JP2,
            operations: [{ method: :lossless, argument: true }] }
        ]
      end
    end
  end
end
