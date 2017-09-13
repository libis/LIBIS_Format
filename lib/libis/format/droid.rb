require 'singleton'

require 'tempfile'
require 'csv'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

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

    class Droid < Libis::Format::IdentificationTool

      protected

      def run_list(filelist)
        output = runner(filelist)
        process_output(output)
      end

      def run_dir(dir, recursive = true)
        profile = profile_file_name
        report = result_file_name
        create_profile(dir, profile, recursive)
        create_report(profile, report)
        parse_report(report)
      end

      def run(file)
        profile = profile_file_name
        report = result_file_name
        create_profile(file, profile)
        create_report(profile, report)
        parse_report(report)
      end

      def runner(file_or_list)
        profile = profile_file_name
        report = result_file_name
        create_profile(file_or_list, profile)
        create_report(profile, report)
        parse_report(report)
      end

      def parse_report(report)
        keys = [:id, :parent_id, :uri, :filepath, :filename, :matchtype, :status, :filesize, :type, :extension, :mod_time, :ext_mismatch, :hash, :format_count, :puid, :format_name, :format_version]
        result = CSV.parse(File.readlines(report).join("\n")).map {|a| Hash[keys.zip(a)]}
        result = CSV.read(report, headers: true, header_converters: [:symbol])
                     .map {|a| Hash[keys.zip(a.values)]}
                     .select {|a| a[:type] == 'File'}
        File.delete report
        result.each do |r|
          r.delete(:id)
          r.delete(:parent_id)
          r.delete(:uri)
          r.delete(:filename)
          r.delete()
          r.delete()
          r.delete()
          r.delete()
          r.delete(:format_count)
          r[:source] = :droid
        end
      end

      def create_report(profile, report)
        args = [
            '-e', report,
            '-p', profile,
            '-q'
        ]
        result = Libis::Tools::Command.run(Libis::Format::Config[:droid_path], *args)

        warn "DROID report errors: #{result[:err].join("\n")}" unless result[:status] == 0
        File.delete profile
      end

      def create_profile(file_or_list, profile, recursive = false)
        args = (file_or_list.is_a?(Array)) ? file_or_list.map(&escape_for_string) : file_or_list.escape_for_string
        args << '-p' << profile << '-q'
        args << '-R' if recursive
        result = Libis::Tools::Command.run(Libis::Format::Config[:droid_path], *args)
        warn "DROID profile errors: #{result[:err].join("\n")}" unless result[:status] == 0
      end

      def profile_file_name
        File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .profile', nil)
      end

      def result_file_name
        File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .csv', nil)
      end

    end

  end
end
