require 'os'
require 'tempfile'
require 'csv'

require 'libis/tools/extend/string'
require 'libis/tools/command'

module Libis
  module Format

    class Droid

      def self.run(file)
        droid_dir = File.join(File.dirname(__FILE__), '..','..','..','bin','droid')
        droid_cmd = File.join(droid_dir, OS.windows? ? 'droid.bat' : 'droid.sh')
        profile = File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .profile', nil)
        report = File.join Dir.tmpdir, Dir::Tmpname.make_tmpname(%w'droid .csv', nil)
        Libis::Tools::Command.run droid_cmd, '-a', file.escape_for_string, '-p', profile, '-q'
        Libis::Tools::Command.run droid_cmd, '-e', report, '-p', profile, '-q'
        File.delete profile
        result = CSV.read(report , headers: true, header_converters: [:downcase, :symbol])
        File.delete report
        result.map{|r|r.to_hash}
      end
    end

  end
end
