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
        transform = false if FastlaneCore::Env.truthy?("FL_SKIP_TABLE_TRANSFORM")

        if transform
          params[:rows] = transform_output(rows, transform)
        else
          params[:rows] = rows
        end

        params[:title] = title.green if title

        puts ""
        puts Terminal::Table.new(params)
        puts ""

        return params
      end

      def colorize_array(array, colors)
        value = ""
        array.each do  |l|
          colored_line = l
          colored_line = "#{colors.first[0]}#{l}#{colors.last[0]}" if colors.length > 0
          value << colored_line
          value << "\n"
        end
        return value
      end

      def transform_output(rows, transform)
        require 'fastlane_core/string_filters'
        require 'tty-screen'

        return_array = []
        tcols = TTY::Screen.width

        col_count = rows.map(&:length).first || 1

        # -4 per column - as tt adds "| " and " |"
        terminal_table_padding = 4
        max_length = tcols - (col_count * terminal_table_padding)

        max_value_length = (max_length / col_count)

        rows.map do |row|
          new_row = []
          row.each do |col|
            value = col.to_s.dup
            if transform == :truncate_middle
              value = value.middle_truncate(max_value_length)
            elsif transform == :newline && value
              # remove all fixed newlines as it may mess up the output
              value.tr!("\n", " ") if value.kind_of?(String)
              if value.length >= max_value_length
                colors = value.scan(/(\e\[.*?m)/)
                if colors && colors.length > 0
                  colors.each do |color|
                    value.delete!(color.first)
                    value.delete!(color.last)
                  end
                end
                lines = value.wordwrap(max_value_length)
                value = colorize_array(lines, colors)
              end
            end
            new_row << value
          end
          return_array << new_row
          return_array << :separator
        end
        return_array.pop
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

          if value.respond_to? :key
            rows.concat self.collect_rows(options: value, hide_keys: hide_keys, mask_keys: mask_keys, prefix: "#{prefix}#{key}.", mask: mask)
          else
            rows << [prefixed_key, value]
          end
        end
        rows
      end
    end
  end
end
