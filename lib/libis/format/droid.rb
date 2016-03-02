require 'singleton'

require 'tempfile'
require 'csv'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format

    class Droid
      include Singleton
      include ::Libis::Tools::Logger

      def self.run(file)
        self.new.run file
      end

      def run(file)
        profile = File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .profile', nil)
        report = File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .csv', nil)
        result = Libis::Tools::Command.run(
            Libis::Format::Config[:droid_path],
            '-a', file.escape_for_string,
            '-p', profile,
            '-q',
        )
        warn "DROID profile errors: #{result[:err].join("\n")}" unless result[:status] == 0
        result = Libis::Tools::Command.run(
            Libis::Format::Config[:droid_path],
            '-e', report,
            '-p', profile,
            '-q'
        )
        warn "DROID report errors: #{result[:err].join("\n")}" unless result[:status] == 0
        File.delete profile
        result = CSV.read(report , headers: true, header_converters: [:downcase, :symbol])
        File.delete report
        result.map{|r|r.to_hash}
      end
    end

  end
end
