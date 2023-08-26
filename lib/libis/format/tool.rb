# code utf-8

module Libis
  module Format
    module Tool

      autoload :Droid, 'libis/format/tool/droid'
      autoload :ExtensionIdentification, 'libis/format/tool/extension_identification'
      autoload :Fido, 'libis/format/tool/fido'
      autoload :FileTool, 'libis/format/tool/file_tool'

      autoload :OfficeToPdf, 'libis/format/tool/office_to_pdf'
      autoload :FFMpeg, 'libis/format/tool/ff_mpeg'
      autoload :FopPdf, 'libis/format/tool/fop_pdf'
      autoload :PdfCopy, 'libis/format/tool/pdf_copy'
      autoload :PdfMerge, 'libis/format/tool/pdf_merge'
      autoload :PdfOptimizer, 'libis/format/tool/pdf_optimizer'
      autoload :PdfSplit, 'libis/format/tool/pdf_split'
      autoload :PdfToPdfa, 'libis/format/tool/pdf_to_pdfa'
      autoload :PdfaValidator, 'libis/format/tool/pdfa_validator'
      autoload :MsgToPdf, 'libis/format/tool/msg_to_pdf'

    end
  end
end
