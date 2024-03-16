# frozen_string_literal: true

require 'thor'
require 'tty-prompt'
require 'tty-config'

require 'libis/format/cli/convert'
require 'libis/format/cli/format'

module Libis
  module Format
    class CommandLine < Thor
      def self.exit_on_failure?
        true
      end

      desc 'convert', 'perform format conversion on a given file'
      subcommand 'convert', Cli::Convert

      desc 'format', 'perform format identification on a given file or directory'
      subcommand 'format', Cli::Format
    end
  end
end
