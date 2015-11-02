module Gym
  class Manager
    def work(options)
      Gym.config = options

      print_summary

      return Runner.new.run
    end

    private

    def print_summary
      FastlaneCore::PrintTable.print_values(config: Gym.config, hide_keys: [], title: "Summary for gym #{Gym::VERSION}")
    end
  end
end
