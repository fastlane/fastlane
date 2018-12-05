require_relative 'configuration/configuration'
require_relative 'helper'

module FastlaneCore
  class PrintTable
    class << self
      # This method prints out all the user inputs in a nice table. Useful to summarize the run
      # You can pass an array to `hide_keys` if you don't want certain elements to show up (symbols or strings)
      # You can pass an array to `mask_keys` if you want to mask certain elements (symbols or strings)
      def print_values(config: nil, title: nil, hide_keys: [], mask_keys: [], transform: :newline)
        require 'terminal-table'

        options = {}
        unless config.nil?
          if config.kind_of?(FastlaneCore::Configuration)
            # find sensitive options and mask them by default
            config.available_options.each do |config_item|
              if config_item.sensitive
                mask_keys << config_item.key.to_s
              end
            end
            options = config.values(ask: false)
          else
            options = config
          end
        end
        rows = self.collect_rows(options: options, hide_keys: hide_keys.map(&:to_s), mask_keys: mask_keys.map(&:to_s), prefix: '')

        params = {}

        if transform
          params[:rows] = transform_output(rows, transform: transform)
        else
          params[:rows] = rows
        end

        params[:title] = title.green if title

        puts("")
        puts(Terminal::Table.new(params))
        puts("")

        return params
      end

      def colorize_array(array, colors)
        value = ""
        array.each do  |l|
          colored_line = l
          colored_line = "#{colors.first}#{l}#{colors.last}" if colors.length > 0
          value << colored_line
          value << "\n"
        end
        return value
      end

      def should_transform?
        if FastlaneCore::Helper.ci? || FastlaneCore::Helper.test?
          return false
        end
        return !FastlaneCore::Env.truthy?("FL_SKIP_TABLE_TRANSFORM")
      end

      def transform_row(column, transform, max_value_length)
        return column if column.nil? # we want to keep the nil and not convert it to a string
        return column if transform.nil?

        value = column.to_s.dup

        if transform == :truncate_middle
          return value.middle_truncate(max_value_length)
        elsif transform == :newline
          # remove all fixed newlines as it may mess up the output
          value.gsub!("\n", " ") if value.kind_of?(String)
          if value.length >= max_value_length
            colors = value.scan(/\e\[.*?m/)
            colors.each { |color| value.gsub!(color, '') }
            lines = value.wordwrap(max_value_length)
            return  colorize_array(lines, colors)
          end
        elsif transform
          UI.user_error!("Unknown transform value '#{transform}'")
        end
        return value
      end

      def transform_output(rows, transform: :newline)
        return rows unless should_transform?

        require 'fastlane_core/string_filters'
        require 'tty-screen'

        number_of_cols = TTY::Screen.width

        col_count = rows.map(&:length).first || 1

        # -4 per column - as tt adds "| " and " |"
        terminal_table_padding = 4
        max_length = number_of_cols - (col_count * terminal_table_padding)

        max_value_length = (max_length / col_count) - 1

        return_array = rows.map do |row|
          row.map do |column|
            transform_row(column, transform, max_value_length)
          end
        end
        return return_array
      end

      def collect_rows(options: nil, hide_keys: [], mask_keys: [], prefix: '', mask: '********')
        rows = []

        options.each do |key, value|
          prefixed_key = "#{prefix}#{key}"
          next if value.nil?
          next if value.to_s == ""
          next if hide_keys.include?(prefixed_key)
          value = mask if mask_keys.include?(prefixed_key)

          if value.respond_to?(:key)
            rows.concat(self.collect_rows(options: value, hide_keys: hide_keys, mask_keys: mask_keys, prefix: "#{prefix}#{key}.", mask: mask))
          else
            rows << [prefixed_key, value]
          end
        end
        rows
      end
    end
  end
end
