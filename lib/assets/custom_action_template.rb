module Fastlane
  module Actions
    module SharedValues
      [[NAME_UP]]_CUSTOM_VALUE = :[[NAME_UP]]_CUSTOM_VALUE
    end

    class [[NAME_CLASS]]
      def self.run(params)
        puts "My Ruby Code!"
        # puts "Parameter: #{params.first}"
        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::[[NAME_UP]]_CUSTOM_VALUE] = "my_val"
      end
    end
  end
end