module Fastlane
  module Actions
    module SharedValues
      [[NAME_UP]]_CUSTOM_VALUE = :[[NAME_UP]]_CUSTOM_VALUE
    end

    def self.[[NAME]](params)
      execute_action("[[NAME]]") do
        Dir.chdir("..") do # go up from the fastlane folder, to the project folder
          puts "My Ruby Code is here"
          # puts "Parameter: #{params.first}"
          # sh_no_action "shellcommand ./path"

          # self.lane_context[SharedValues::[[NAME_UP]]_CUSTOM_VALUE] = "my_val"
        end
      end
    end
  end
end