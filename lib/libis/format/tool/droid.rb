require 'singleton'

require 'tempfile'
require 'csv'

require 'libis/format/config'

unless CSV::HeaderConverters.has_key?(:droid_headers)
  CSV::HeaderConverters[:droid_headers] = lambda {|h|
    h.encode(ConverterEncoding).downcase.strip.
        gsub(/\W+/, "").to_sym
  }
end

require_relative 'identification_tool'

module Libis
  module Format
    module Tool

      class Droid < Libis::Format::Tool::IdentificationTool

        def run_list(filelist, _options = {})
          runner(filelist)
        end

        def run_dir(dir, recursive = true, _options = {})
          runner(dir, recursive)
        end

        def run(file, _options = {})
          runner(file)
        end

        protected

        def runner(file_or_list, recursive = false)
          profile = profile_file_name
          report = result_file_name
          create_profile(file_or_list, profile, recursive)
          create_report(profile, report)
          parse_report(report)
        end

        def parse_report(report)
          keys = [
              :id, :parent_id, :uri, :filepath, :filename, :matchtype, :status, :filesize, :type, :extension,
              :mod_time, :ext_mismatch, :hash, :format_count, :puid, :mimetype, :format_name, :format_version]
          result = CSV.parse(File.readlines(report).join)
                       .map {|a| Hash[keys.zip(a)]}
                       .select {|a| a[:type] == 'File'}
          # File.delete report
          result.each do |r|
            r.delete(:id)
            r.delete(:parent_id)
            r.delete(:uri)
            r.delete(:filename)
            r.delete(:status)
            r.delete(:filesize)
            r.delete(:type)
            r.delete(:extension)
            r.delete(:mod_time)
            r.delete(:hash)
            r.delete(:format_count)
            r[:tool] = :droid
          end
          File.delete report
          process_output(result)
        end

        def create_report(profile, report)
          args = [
              '-e', report,
              '-p', profile,
              '-q'
          ]
          timeout = Libis::Format::Config[:timeouts][:droid]
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:droid_cmd], *args,
              timeout: timeout,
              kill_after: timeout * 2
          )
          result[:err].select! {|x| x =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} ERROR /}
          raise RuntimeError, "#{self.class} report took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} report errors: #{result[:err].join("\n")}" unless result[:err].empty?

          File.delete profile
        end

        def create_profile(file_or_list, profile, recursive = false)
          args = []
          files = (file_or_list.is_a?(Array)) ? file_or_list.map(&:escape_for_string) : [file_or_list.escape_for_string]
          files.each {|file| args << '-a' << file}
          args << '-q'
          args << '-p' << profile
          args << '-R' if recursive
          timeout = Libis::Format::Config[:timeouts][:droid]
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:droid_cmd], *args,
              timeout: timeout,
              kill_after: timeout * 2
          )
          result[:err].select! {|x| x =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} ERROR /}
          raise RuntimeError, "#{self.class} profile took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} profile errors: #{result[:err].join("\n")}" unless result[:err].empty?
        end

        def profile_file_name
          Tools::TempFile.name('droid', '.profile')
        end

        def result_file_name
          Tools::TempFile.name('droid', '.csv')
        end

      end

    end
  end
end
