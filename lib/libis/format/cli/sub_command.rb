require 'thor'
require_relative 'prompt_helper'

module Libis
  module Format
    module Cli
      class SubCommand < Thor

        include PromptHelper

        def self.banner(command, namespace = nil, subcommand = false)
          "#{basename} #{subcommand_prefix} #{command.usage}"
        end

        def self.subcommand_prefix
          self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
        end

      end
    end
  end
end