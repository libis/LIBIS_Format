# code utf-8

module Libis
  module Format
    module Tool

      autoload :Droid, 'libis/format/tool/droid'
      autoload :ExtensionIdentification, 'libis/format/tool/extension_identification'
      autoload :Fido, 'libis/format/tool/fido'
      autoload :FileTool, 'libis/format/tool/file_tool'

      autoload :OfficeToPdf, 'libis/format/tool/office_to_pdf'
      autoload :FFMpeg, 'libis/format/tool/ffmpeg'
      autoload :FopPdf, 'libis/format/tool/fop_pdf'
      autoload :PdfMerge, 'libis/format/tool/pdf_merge'
      autoload :PdfMetadata, 'libis/format/tool/pdf_metadata'
      autoload :PdfOptimizer, 'libis/format/tool/pdf_optimizer'
      autoload :PdfProtect, 'libis/format/tool/pdf_protect'
      autoload :PdfSelect, 'libis/format/tool/pdf_select'
      autoload :PdfSplit, 'libis/format/tool/pdf_split'
      autoload :PdfWatermark, 'libis/format/tool/pdf_watermark'
      autoload :PdfToPdfa, 'libis/format/tool/pdf_to_pdfa'
      autoload :PdfaValidator, 'libis/format/tool/pdfa_validator'

    end
  end
end
