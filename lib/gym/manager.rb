module Gym
  class Manager
    def work(options)
      Gym.project = Project.new(options)
      Gym.config = options

      return Runner.new.run
    end
  end
end
