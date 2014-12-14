module Fastlane
  module Actions
    def self.say(params)

      execute_action("say") do
        text = params.join(' ')
        sh_no_action("say '#{text}'")
      end

    end
  end
end