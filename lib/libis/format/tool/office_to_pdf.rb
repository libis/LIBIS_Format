# frozen_string_literal: true

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

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:soffice_cmd], '--version')
          (result[:status]).zero?
        end

        def self.run(source, target, **options)
          new.run source, target, **options
        end

        def run(source, target, **options)
          workdir = '/...'
          workdir = Dir.tmpdir unless Dir.exist? workdir

          workdir = File.join(workdir, rand(1_000_000).to_s)
          FileUtils.mkpath(workdir)

          src_file = File.join(workdir, File.basename(source))
          FileUtils.symlink source, src_file

          tgt_file = File.join(workdir, "#{File.basename(source, '.*')}.pdf")

          export_filter = options[:export_filter] || 'pdf'

          timeout = Libis::Format::Config[:timeouts][:office_to_pdf]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:soffice_cmd], '--headless',
            "-env:UserInstallation=file://#{workdir}",
            '--convert-to', export_filter,
            '--outdir', workdir, src_file,
            timeout:,
            kill_after: timeout * 2
          )

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

          warn "OfficeToPdf conversion messages: \n\t#{result[:err].join("\n\t")}" unless result[:err].empty?
          raise "#{self.class} failed to generate target file #{tgt_file}" unless File.exist?(tgt_file)

          FileUtils.copy tgt_file, target, preserve: true

          {
            command: result,
            files: [target]
          }
        ensure
          begin
            FileUtils.rmtree workdir
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
