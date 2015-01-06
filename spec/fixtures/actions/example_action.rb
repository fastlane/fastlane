module Fastlane
  module Actions
    def self.example_action(params)

      execute_action("example_action") do
        File.write("/tmp/example_action.txt", Time.now.to_i)
      end

    end
  end
end