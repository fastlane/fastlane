module Attach
  class Manager
    def work(options)
      Attach.project = Project.new(options)
      Attach.config = options

      return Runner.new.run
    end
  end
end
