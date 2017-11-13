require 'libis/format/version'

module Libis
  module Format
    autoload :Config, 'libis/format/config'
    autoload :TypeDatabase, 'libis/format/type_database'
    autoload :Identifier, 'libis/format/identifier'
    autoload :Identifier, 'libis/format/identifier'

    autoload :FileTool, 'libis/format/file_tool'
    autoload :Fido, 'libis/format/fido'
    autoload :Droid, 'libis/format/droid'
    autoload :ExtensionIdentification, 'libis/format/extension_identification'

    autoload :OfficeToPdf, 'libis/format/office_to_pdf'
    autoload :PdfCopy, 'libis/format/pdf_copy'
    autoload :PdfMerge, 'libis/format/pdf_merge'
    autoload :PdfOptimizer, 'libis/format/pdf_optimizer'
    autoload :PdfSplit, 'libis/format/pdf_split'
    autoload :PdfToPdfa, 'libis/format/pdf_to_pdfa'
    autoload :PdfaValidator, 'libis/format/pdfa_validator'
    autoload :FFMpeg, 'libis/format/ffmpeg'

    autoload :Converter, 'libis/format/converter'

    ROOT_DIR = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
    DATA_DIR = File.join(ROOT_DIR, 'data')

  end
end