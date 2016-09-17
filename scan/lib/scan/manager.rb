module Scan
  class Manager
    def work(options)
      Scan.config = options

      FastlaneCore::PrintTable.print_values(config: options,
                                         hide_keys: [:destination, :slack_url],
                                             title: "Summary for scan #{Scan::VERSION}")

      return Runner.new.run
    end
  end
end
