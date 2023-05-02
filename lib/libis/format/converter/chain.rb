# coding: utf-8

require 'fileutils'
require 'deep_dive'

require 'libis/tools/logger'
require 'libis/tools/extend/hash'
require 'libis/format/type_database'

module Libis
  module Format
    module Converter

      class Chain
        include ::Libis::Tools::Logger
        include DeepDive

        def initialize(source_format, target_format, operations = {})
          @source_format = source_format.to_sym
          @target_format = target_format.to_sym
          @operations = operations || {}
          @converter_chain = []
        end

        # @param [Libis::Format::Converter::Base.class] converter
        # @return [Array[Hash]]
        def append(converter)
          return [] unless converter
          valid_chain_nodes(converter).map do |node|
            self.ddup.add_chain_node(node)
          end.compact
        end

        def closed?
          !@converter_chain.empty? &&
              @converter_chain.first[:input].to_sym == @source_format &&
              @converter_chain.last[:output].to_sym == @target_format
        end

        def valid?
          closed? && apply_operations
        end

        def to_array
          @converter_chain
        end

        def size
          @converter_chain.size
        end

        alias_method :length, :size

        def to_s
          "#{@source_format}->-#{@converter_chain.map do |node|
            "#{node[:converter].name.gsub(/^.*::/, '')}#{node[:operations].empty? ? '' :
                "(#{node[:operations].each do |operation|
                  "#{operation[:method]}:#{operation[:argument]}"
                end.join(',')})"}->-#{node[:output]}"
          end.join('->-')}"
        end

        def convert(src_file, target_file)

          unless valid?
            error 'Converter chain is not valid'
            return nil
          end

          temp_files = []

          result = { commands: [] }

          # noinspection RubyParenthesesAroundConditionInspection
          result = @converter_chain.each_with_index do |node, i|

            target_type = node[:output]
            converter_class = node[:converter]
            converter = converter_class.new

            node[:operations].each do |operation|
              converter.send operation[:method], operation[:argument]
            end if node[:operations]

            target = target_file

            if i < size - 1
              target += ".temp.#{TypeDatabase.type_extentions(target_type).first}"
              target += ".#{TypeDatabase.type_extentions(target_type).first}" while File.exist? target
              temp_files << target
            end

            FileUtils.mkdir_p File.dirname(target)

            r = converter.convert(src_file, target, target_type)

            src_file = r[:files].first
            break :failed unless src_file

            result[:commands] << r.merge(converter: converter_class.name)

            if i == size - 1
              result[files:] = r[:files]
            end
          end

          result[:files] = result[:commands].last[:files]

          temp_files.each do |f|
            FileUtils.rm(f, force: true)
          end

          result == :failed ? nil : target_file

        end

        def valid_chain_nodes(converter)
          source_format = @converter_chain.last[:output] rescue @source_format
          nodes = []
          if converter.input_types.include? source_format
            converter.output_types(source_format).each do |format|
              node = {converter: converter, input: source_format, output: format}
              next if node_exists?(node)
              nodes << node
            end
          end
          nodes
        end

        def add_chain_node(node = {})
          last_converter = @converter_chain.last
          source_format = last_converter ? last_converter[:output] : @source_format
          node[:input] ||= source_format
          return nil unless node[:input] == source_format
          return nil unless node[:output] && node[:converter].output_types(source_format).include?(node[:output])
          return nil unless node[:converter].input_types.include? source_format
          return nil if node_exists?(node)
          @converter_chain << node
          # debug "Chain: #{self}"
          self
        end

        def apply_operations
          temp_chain = @converter_chain.reverse.ddup
          applied = true
          operations = @operations && @operations.ddup || {}
          while (operation = operations.shift)
            method = operation.first.to_s.to_sym
            applied &&= :found == temp_chain.each do |node|
              next unless node[:converter].instance_methods.include?(method)
              node[:operations] ||= []
              node[:operations] << {method: method, argument: operation.last}
              break :found
            end
          end
          if applied && operations.empty?
            @converter_chain = temp_chain.reverse
            @operations.clear
            return true
          end
          false
        end


        private

        def node_exists?(node)
          @converter_chain.detect do |n|
            n[:converter] == node[:converter] && n[:input] == node[:input] && n[:output] == node[:output]
          end
        end

      end

    end
  end
end
