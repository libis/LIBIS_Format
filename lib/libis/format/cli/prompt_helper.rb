require 'tty-prompt'
require 'pastel'

module Libis
  module Format
    module Cli
      module PromptHelper

        attr_reader :prompt, :pastel

        def initialize(*args)
          @prompt = TTY::Prompt.new
          @pastel = Pastel.new
          super
        end

        protected

        private

        def index_of(list, value)
          i = list.index(value)
          i += 1 if i
          i || 1
        end

        def ask(question, bool: false, enum: nil, default: nil, mask: false)
          cmd, args, opts = :ask, [question], {}
          if enum
            cmd = :select
            args << enum
            # Change default to its index in the enum
            default = index_of(enum, default)
          end
          cmd = :mask if mask
          opts[:default] = default if default
          cmd = (opts[:default] ? :yes? : :no?) if bool
          prompt.send(cmd, *args, opts)
        end

        def tree_select(path, question: nil, file: false, page_size: 22, filter: true, cycle: false, create: false,
                        default_choices: nil)
          path = Pathname.new(path) unless path.is_a? Pathname

          return path unless path.exist?
          path = path.realpath

          dirs = path.children.select(&:directory?).sort
          files = file ? path.children.select(&:file?).sort : []

          choices = []
          choices << {name: "Folder: #{path}", value: path, disabled: file ? '' : false}
          choices += default_choices if default_choices
          choices << {name: '-- new directory --', value: -> do
            new_name = prompt.ask('new directory name:', modify: :trim, required: true)
            new_path = path + new_name
            FileUtils.mkdir(new_path.to_path)
            new_path
          end
          } if create

          choices << {name: "-- new file --", value: -> do
            new_name = prompt.ask('new file name:', modify: :trim, required: true)
            path + new_name
          end
          } if file && create

          choices << {name: '[..]', value: path.parent}

          dirs.each {|d| choices << {name: "[#{d.basename}]", value: d}}
          files.each {|f| choices << {name: f.basename.to_path, value: f}}

          question ||= "Select #{'file or ' if files}directory"
          selection = prompt.select question, choices,
                                    per_page: page_size, filter: filter, cycle: cycle, default: file ? 2 : 1

          return selection unless selection.is_a? Pathname
          return selection.to_path if selection == path || selection.file?

          tree_select selection, question: question, file: file, page_size: page_size, filter: filter,
                      cycle: cycle, create: create, default_choices: default_choices
        end

      end
    end
  end
end