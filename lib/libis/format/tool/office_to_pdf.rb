require 'fileutils'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool

      class OfficeToPdf
        include ::Libis::Tools::Logger

        def self.run(source, target, options = {})
          self.new.run source, target, options
        end

        def run(source, target, options = {})
          workdir = '/...'
          workdir = Dir.tmpdir unless Dir.exist? workdir

          workdir = File.join(workdir, rand(1000000).to_s)
          FileUtils.mkpath(workdir)

          src_file = File.join(workdir, File.basename(source))
          FileUtils.symlink source, src_file

          tgt_file = File.join(workdir, File.basename(source, '.*') + '.pdf')

          export_filter = options[:export_filter] || 'pdf'

          result = Libis::Tools::Command.run(
              Libis::Format::Config[:soffice_path], '--headless',
              '--convert-to', export_filter,
              '--outdir', workdir, src_file
          )

          unless result[:status] == 0
            warn "PdfConvert errors: #{(result[:err] + result[:out]).join("\n")}"
            return false
          end

          FileUtils.copy tgt_file, target, preserve: true
          FileUtils.rmtree workdir

          result[:out]
        end
      end

    end
  end
end
