module Fastlane
  module Actions
    def self.increment_build_number(params)
      # More information about how to set up your project and how it works: 
      # https://developer.apple.com/library/ios/qa/qa1827/_index.html
      # Attention: This is NOT the version number - but the build number

      begin
        execute_action("increment_build_number") do
          Dir.chdir("..") do
            custom_number = (params.first rescue nil)
            if custom_number
              return sh "agvtool new-version -all #{custom_number}"
            else
              return sh "agvtool next-version -all"
            end
          end
        end
      rescue => ex
        Helper.log.error "Make sure to to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html".yellow
        raise ex
      end
    end
  end
end