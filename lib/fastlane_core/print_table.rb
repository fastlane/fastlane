module FastlaneCore
  class PrintTable
    class << self
      # This method prints out all the user inputs in a nice table. Useful to summarize the run
      # You can pass an array to `hide_key` if you don't want certain elements to show up (symbols)
      def print_values(config: nil, title: nil, hide_keys: [])
        require 'terminal-table'
        rows = []

        config.available_options.each do |config_item|
          value = config[config_item.key]
          next if value.nil?
          next if value.to_s == ""
          next if hide_keys.include?(config_item.key)

          rows << [config_item.key, value]
        end

        params = {}
        params[:rows] = rows
        params[:title] = title if title

        puts ""
        puts Terminal::Table.new(params)
        puts ""

        return params
      end
    end
  end
end
