module Fastlane
  module Actions
    def self.install_cocoapods(params)
      execute_action("cocoapods") do
        Dir.chdir("..") do
          return sh_no_action("pod install")
        end
      end
    end
  end
end