module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER = :BUILD_NUMBER
    end

    class IncrementBuildNumberAction
      def self.run(params)
        # More information about how to set up your project and how it works: 
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html
        # Attention: This is NOT the version number - but the build number

        begin
          custom_number = (params.first rescue nil)

          command = nil
          if custom_number
            command = "agvtool new-version -all #{custom_number}"
          else
            command = "agvtool next-version -all"
          end

          if Helper.is_test?
            build_number = command
          else

            Actions.sh command

            # Store the new number in the shared hash
            build_number = `agvtool what-version`.split("\n").last.to_i

            Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
            
          end
        rescue => ex
          Helper.log.error "Make sure to to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html".yellow
          raise ex
        end
      end
    end
  end
end