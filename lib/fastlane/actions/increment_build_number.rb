module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER = :BUILD_NUMBER
    end

    def self.increment_build_number(params)
      # More information about how to set up your project and how it works: 
      # https://developer.apple.com/library/ios/qa/qa1827/_index.html
      # Attention: This is NOT the version number - but the build number

      begin
        execute_action("increment_build_number") do
          Dir.chdir("..") do
            custom_number = (params.first rescue nil)
            if custom_number
              sh_no_action "agvtool new-version -all #{custom_number}"
            else
              sh_no_action "agvtool next-version -all"
            end

            # Store the new number in the shared hash
            build_number = `agvtool what-version`.split("\n").last.to_i
            self.shared_hash[SharedValues::BUILD_NUMBER] = build_number if build_number > 0
          end
        end
      rescue => ex
        Helper.log.error "Make sure to to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html".yellow
        raise ex
      end
    end
  end
end