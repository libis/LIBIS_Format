[![Gem Version](https://badge.fury.io/rb/libis-format.svg)](http://badge.fury.io/rb/libis-format)
[![Build Status](https://travis-ci.org/Kris-LIBIS/LIBIS_Format.svg?branch=master)](https://travis-ci.org/Kris-LIBIS/LIBIS_Format)
[![Coverage Status](https://img.shields.io/coveralls/Kris-LIBIS/LIBIS_Format.svg)](https://coveralls.io/r/Kris-LIBIS/LIBIS_Format)
[![Dependency Status](https://gemnasium.com/Kris-LIBIS/LIBIS_Format.svg)](https://gemnasium.com/Kris-LIBIS/LIBIS_Format)

# libis-format

This gem provides functionality for format identification and conversion. Converters may rely on the presence of
3rd party software, so read the class documentation carefully for the converters you want to use.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'libis-format'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libis-format

## Usage

### ::Libis::Format::Library

The format database is the core of the format services. It stores information about all the known formats.

### ::Libis::Format::Identifier

This class enables support for format identification. It will use 3 external tools to identify a file format:
droid, fido and the unix file tool. Based on several criteria, the results of these tools will be given a
score and the result with the highest confidence is returned. The output of all tools can also be returned.
The format identification result contains a MIME-type and a PRONOM PUID if they are known. Also the calculated
score, the tool that produced the outcome and recognition method are listed. Some tools also return more
information like the format name and format version. If these are present on the most confident output, their
values will also be part of the result info.

Unidentified files will be listed with MIME-type 'application/octet-stream' and PUID 'fmt/unknown'.

The main method #get that performs the format identification takes two parameters:
- file: can be a string representing a file or directory path, but also an array of file paths.
- options: optional hash with parameters that influence the behaviour of the format identification process

The options has accespts the following keys (Symbol types):
- :droid
  Boolean if set to false will not use the Droid tool. Default: true
- :fido
  Boolean if set to false will not use the Fido tool. Default: true
- :file
  Boolean if set to false will not use the Unix file tool. Default: true
- :tool
  Symbol either :droid, :fido or :file. A shortcut option for setting only the given value to true.
- :xml_validation
  Boolean if set to false will not perform XML validation (see below)
- :recursive
  Boolean if set to true and a directory is passed as first argument, Identifier will parse the
  directory tree recursively and will process all files found. Default: false
- :base_dir
  String. Normally file will be referenced by their absolute path in the results. If a value is
  supplied for this option, the given path will be stripped from the start of the file references in the
  result. Default: nil.
- :keep_output
  Boolean if set will store the output of each identification tool in the result structure. Default: false

The result of the identification is a Hash with the following keys:
- :messages
  a list (Array) of error and warning messages that the Identifier or one of the tools used has generated.
  Each entry is another Array with the first argument the severity of the message and the second one the
  message itself.
- :output
  optional output of each tool as an Array with an entry per tool and grouped into a Hash by file reference.
- :formats
  a Hash with file references as key and the outcome of the identification as value.

The identification outcome is a Hash of key-value pairs for each property returned. Keys are lower-case
symbols. If the tools gave results that deffer in a significant part, their outcome will be added to a list as
:alternatives (see example).

#### XML Validation

None of the tools used is able to identify an XML file by its content. In our context this is especially
annoying for EAD XML files as we want to identify them in order to process them different from the other XML
files. The Identifier solves this by performing an extra check on files identified as XML files. It will
validate each XML file against a list of XML schemas and return the matching MIME-type in the result. If the
Type Database contains an entry for this format, the result will be extended with the information from the
Type Database.

With the :xml_validation option this behaviour can be turned off, for instance in cases where no EAD files are
to be expected or no further identification of XML files is needed. Note that if no XML files are present, the
Identifier will not spend any time on XML validation anyway.

The list of validation schemas can be extended with the class method #add_xml_validation which takes two
parameters: a MIME-type and the path to an XML schema (XSD). If you want to also assign a fictuous PUID to the
XML type you should add an entry to your Type Database with the same MIME-type.

### Example

```
```

```
{
    :messages => [
        [0] [
            [0] :debug,
            [1] "XML file validated against XML Schema: [...]/data/ead.xsd"
        ],
        [1] [
            [0] :debug,
            [1] "XML file validated against XML Schema: [...]/data/ead.xsd"
        ],
        [2] [
            [0] :debug,
            [1] "XML file validated against XML Schema: [...]/data/ead.xsd"
        ]
    ],
    :output => {
        "[...]/data/Cevennes2.bmp" => [
            [0] {
                     :matchtype => "signature",
                  :ext_mismatch => "false",
                          :puid => "fmt/116",
                      :mimetype => "image/bmp",
                   :format_name => "Windows Bitmap",
                :format_version => "3.0",
                          :tool => :droid,
                          :TYPE => :BMP,
                         :GROUP => :IMAGE,
                         :score => 7
            },
            [1] {
                          :puid => "fmt/116",
                   :format_name => "Windows Bitmap",
                :format_version => "Windows Bitmap 3.0",
                      :mimetype => "image/bmp",
                     :matchtype => "signature",
                          :tool => :fido,
                          :TYPE => :BMP,
                         :GROUP => :IMAGE,
                         :score => 7
            },
            [2] {
                 :mimetype => "image/bmp",
                :matchtype => "magic",
                     :tool => :file,
                     :TYPE => :BMP,
                    :GROUP => :IMAGE,
                    :score => 2
            }
        ],
        "[...]/data/Cevennes2.jp2" => [
            [0] {
                     :matchtype => "signature",
                  :ext_mismatch => "false",
                          :puid => "x-fmt/392",
                      :mimetype => "image/jp2",
                   :format_name => "JP2 (JPEG 2000 part 1)",
                :format_version => "",
                          :tool => :droid,
                          :TYPE => :JP2,
                         :GROUP => :IMAGE,
                         :score => 7
            },
            [1] {
                          :puid => "x-fmt/392",
                   :format_name => "JP2 (JPEG 2000 part 1)",
                :format_version => "JPEG2000",
                      :mimetype => "image/jp2",
                     :matchtype => "signature",
                          :tool => :fido,
                          :TYPE => :JP2,
                         :GROUP => :IMAGE,
                         :score => 7
            },
            [2] {
                 :mimetype => "image/jp2",
                :matchtype => "magic",
                     :tool => :file,
                     :TYPE => :JP2,
                    :GROUP => :IMAGE,
                    :score => 2
            }
        ],
        [...]
     },
     :formats => {
        "[...]/data/Cevennes2.bmp" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "fmt/116",
                  :mimetype => "image/bmp",
               :format_name => "Windows Bitmap",
            :format_version => "3.0",
                      :tool => :droid,
                      :TYPE => :BMP,
                     :GROUP => :IMAGE,
                     :score => 7
        },
        "[...]/data/Cevennes2.jp2" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "x-fmt/392",
                  :mimetype => "image/jp2",
               :format_name => "JP2 (JPEG 2000 part 1)",
            :format_version => "JPEG2000",
                      :tool => :droid,
                      :TYPE => :JP2,
                     :GROUP => :IMAGE,
                     :score => 7
        },
        "[...]/data/NikonRaw-CameraRaw.TIF" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "fmt/353",
                  :mimetype => "image/tiff",
               :format_name => "Tagged Image File Format",
            :format_version => "TIFF generic (little-endian)",
                      :tool => :droid,
                      :TYPE => :TIFF,
                     :GROUP => :IMAGE,
                     :score => 7
        },
        "[...]/data/NikonRaw-CaptureOne.tif" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "x-fmt/387",
                  :mimetype => "image/tiff",
               :format_name => "Exchangeable Image File Format (Uncompressed)",
            :format_version => "2.2",
                      :tool => :droid,
                      :TYPE => :TIFF,
                     :GROUP => :IMAGE,
                     :score => 7,
              :alternatives => [
                [0] {
                              :puid => "fmt/353",
                       :format_name => "Tagged Image File Format",
                    :format_version => "TIFF generic (little-endian)",
                          :mimetype => "image/tiff",
                         :matchtype => "signature",
                              :tool => :fido,
                              :TYPE => :TIFF,
                             :GROUP => :IMAGE,
                             :score => 7
                },
                [1] {
                         :matchtype => "signature",
                      :ext_mismatch => "false",
                              :puid => "x-fmt/387",
                          :mimetype => "image/tiff",
                       :format_name => "Exchangeable Image File Format (Uncompressed)",
                    :format_version => "2.2",
                              :tool => :droid,
                              :TYPE => :TIFF,
                             :GROUP => :IMAGE,
                             :score => 7
                }
            ]
        },
        "[...]/data/test-ead.xml" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "fmt/101",
                  :mimetype => "archive/ead",
               :format_name => "Encoded Archival Description (EAD)",
            :format_version => "",
                      :tool => :xsd_validation,
                      :TYPE => :EAD,
                     :GROUP => :ARCHIVE,
                     :score => 7,
                      :tool => :droid,
                :match_type => "xsd_validation"
        },
        "[...]/data/test.doc" => {
                 :matchtype => "container",
              :ext_mismatch => "false",
                      :puid => "fmt/40",
                  :mimetype => "application/msword",
               :format_name => "Microsoft Word Document",
            :format_version => "97-2003",
                      :tool => :droid,
                      :TYPE => :MSDOC,
                     :GROUP => :TEXT,
                     :score => 9,
              :alternatives => [
                [0] {
                         :matchtype => "container",
                      :ext_mismatch => "false",
                              :puid => "fmt/40",
                          :mimetype => "application/msword",
                       :format_name => "Microsoft Word Document",
                    :format_version => "97-2003",
                              :tool => :droid,
                              :TYPE => :MSDOC,
                             :GROUP => :TEXT,
                             :score => 9
                },
                [1] {
                              :puid => "fmt/111",
                       :format_name => "OLE2 Compound Document Format",
                    :format_version => "OLE2 Compound Document Format",
                          :mimetype => nil,
                         :matchtype => "signature",
                              :tool => :fido,
                             :score => 3
                }
            ]
        },
        "[...]/data/test.docx" => {
                 :matchtype => "container",
              :ext_mismatch => "false",
                      :puid => "fmt/412",
                  :mimetype => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
               :format_name => "Microsoft Word for Windows",
            :format_version => "2007 onwards",
                      :tool => :droid,
                      :TYPE => :MSDOCX,
                     :GROUP => :TEXT,
                     :score => 9
        },
        "[...]/data/test.xlsx" => {
                 :matchtype => "container",
              :ext_mismatch => "false",
                      :puid => "fmt/214",
                  :mimetype => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
               :format_name => "Microsoft Excel for Windows",
            :format_version => "2007 onwards",
                      :tool => :droid,
                      :TYPE => :MSXLSX,
                     :GROUP => :TABULAR,
                     :score => 9,
              :alternatives => [
                [0] {
                         :matchtype => "container",
                      :ext_mismatch => "false",
                              :puid => "fmt/214",
                          :mimetype => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                       :format_name => "Microsoft Excel for Windows",
                    :format_version => "2007 onwards",
                              :tool => :droid,
                              :TYPE => :MSXLSX,
                             :GROUP => :TABULAR,
                             :score => 9
                },
                [1] {
                     :mimetype => "application/octet-stream",
                    :matchtype => "magic",
                         :tool => :file,
                        :score => -2
                }
            ]
        },
        "[...]/data/test_pdfa.pdf" => {
                 :matchtype => "signature",
              :ext_mismatch => "false",
                      :puid => "fmt/354",
                  :mimetype => "application/pdf",
               :format_name => "Acrobat PDF/A - Portable Document Format",
            :format_version => "1b",
                      :tool => :droid,
                      :TYPE => :PDFA,
                     :GROUP => :TEXT,
                     :score => 7,
              :alternatives => [
                [0] {
                              :puid => "fmt/19",
                       :format_name => "Acrobat PDF 1.5 - Portable Document Format",
                    :format_version => "PDF 1.5",
                          :mimetype => "application/pdf",
                         :matchtype => "signature",
                              :tool => :fido,
                              :TYPE => :PDF,
                             :GROUP => :TEXT,
                             :score => 7
                },
                [1] {
                         :matchtype => "signature",
                      :ext_mismatch => "false",
                              :puid => "fmt/354",
                          :mimetype => "application/pdf",
                       :format_name => "Acrobat PDF/A - Portable Document Format",
                    :format_version => "1b",
                              :tool => :droid,
                              :TYPE => :PDFA,
                             :GROUP => :TEXT,
                             :score => 7
                }
            ]
        }
    }
}
```
## Contributing

1. Fork it ( https://github.com/Kris-LIBIS/LIBIS_Format/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
