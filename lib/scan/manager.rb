module Scan
  class Manager
    def work(options)
      Scan.config = options

      FastlaneCore::PrintTable.print_values(config: options, hide_keys: [:destination], title: "Summary")

      return Runner.new.run
    end
  end
end
