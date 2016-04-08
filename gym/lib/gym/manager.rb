module Gym
  class Manager
    def work(options)
      Gym.config = options

      FastlaneCore::PrintTable.print_values(config: Gym.config,
                                         hide_keys: [],
                                             title: "Summary for gym #{Gym::VERSION}")

      return Runner.new.run
    end
  end
end
