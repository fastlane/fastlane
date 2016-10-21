describe Fastlane do
  describe Fastlane::Action do
    describe "Options" do
      let (:all_exceptions) { %w(pilot appstore cert deliver gym match pem produce scan sigh snapshot supply testflight mailgun testfairy ipa import_from_git hockey deploygate crashlytics artifactory appledoc slather screengrab download_dsyms notification frameit set_changelog register_devices latest_testflight_build_number) }

      Fastlane::ActionsList.all_actions do |action, name|
        next unless action.available_options.kind_of?(Array)
        next unless action.available_options.last.kind_of?(FastlaneCore::ConfigItem)

        it "No unused parameters in '#{name}'" do
          next if all_exceptions.include?(name)
          content = File.read(File.join("lib", "fastlane", "actions", name + ".rb"))
          action.available_options.each do |option|
            unless content.include?("[:#{option.key}]")
              UI.user_error!("Action '#{name}' doesn't use the option :#{option.key}")
            end
          end
        end

        it "Every environment variable is prefixed in '#{name}'", :env_action => name do
          action.available_options.map(&:env_name).reject(&:nil?).each do |env_name|
            if name == 'fastlane'
              env_name.should start_with("FL_")
            else
              prefix = name.upcase
              expect(env_name).to start_with("#{prefix}_").or start_with("FL_#{prefix}_")
            end
          end
        end
      end
    end
  end
end
