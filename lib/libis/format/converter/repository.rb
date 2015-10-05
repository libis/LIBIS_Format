# coding: utf-8

require 'set'
require 'singleton'

require 'libis/tools/logger'
require 'libis/format/config'

require_relative 'chain'

module Libis
  module Format
    module Converter

      class Repository
        include Singleton
        include ::Libis::Tools::Logger

        attr_reader :converters
        attr_accessor :converters_glob

        def initialize
          @converters = Set.new
          @converters_glob = File.join(File.dirname(__FILE__), '*_converter.rb')
        end

        def Repository.register(converter_class)
          instance.converters.add? converter_class
        end

        def Repository.get_converters
          instance.get_converters
        end

        def get_converters
          if converters.empty?
            Dir.glob(converters_glob).each do |filename|
              # noinspection RubyResolve
              require File.expand_path(filename)
            end
          end
          converters
        end

        def Repository.get_converter_chain(src_type, tgt_type, operations = {})
          instance.get_converter_chain src_type, tgt_type, operations
        end

        def get_converter_chain(src_type, tgt_type, operations = {})
          msg = "conversion from #{src_type.to_s} to #{tgt_type.to_s}"
          chain_list = find_chains src_type, tgt_type, operations
          if chain_list.length > 1
            warn "Found more than one conversion chain for #{msg}. Picking the first one."
          end
          if chain_list.empty?
            error "No conversion chain found for #{msg}"
            return nil
          end
          chain_list.each do |chain|
            debug "Matched chain: #{chain}"
          end
          chain_list[0]
        end

        private

        def find_chains(src_type, tgt_type, operations)
          chain = Libis::Format::Converter::Chain.new(src_type, tgt_type, operations)
          build_chains(chain)
        end

        def build_chains(chain)

          found = []
          chains = [chain]

          # Avoid chains that are too long
          Libis::Format::Config[:converter_chain_max_level].times do
            new_chains = []
            get_converters.each do |converter|
              new_chains += chains.map { |c| c.append(converter) }.flatten
            end

            found = new_chains.select { |c| c.valid?}
            return found unless found.empty?

            chains = new_chains
          end

          found

        end

      end

    end
  end
end
