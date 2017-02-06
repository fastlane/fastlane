module FastlaneCore
  class PrintTable
    class << self
      # This method prints out all the user inputs in a nice table. Useful to summarize the run
      # You can pass an array to `hide_keys` if you don't want certain elements to show up (symbols or strings)
      # You can pass an array to `mask_keys` if you want to mask certain elements (symbols or strings)
      def print_values(config: nil, title: nil, hide_keys: [], mask_keys: [])
        

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
        params[:rows] = FastlaneCore::TerminalTable.limit_row_size(rows)
        params[:title] = title.green if title

        puts ""
        puts FastlaneCore::TerminalTable.new(params)
        puts ""

        return params
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
