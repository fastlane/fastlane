describe Fastlane do
  describe Fastlane::Action do
    describe "Options" do
      let (:all_exceptions) { %w(pilot appstore cert deliver gym match pem produce scan sigh snapshot supply testflight mailgun testfairy ipa import_from_git hockey deploygate crashlytics artifactory appledoc slather screengrab download_dsyms notification frameit set_changelog register_devices latest_testflight_build_number) }

      Fastlane::ActionsList.all_actions do |action, name|
        next unless action.available_options.kind_of?(Array)
        next unless action.available_options.last.kind_of?(FastlaneCore::ConfigItem)

        it "No unused parameters in '#{name}'", action: name do
          next if all_exceptions.include?(name)
          content = File.read(File.join("lib", "fastlane", "actions", name + ".rb"))
          action.available_options.each do |option|
            unless content.include?("[:#{option.key}]")
              UI.user_error!("Action '#{name}' doesn't use the option :#{option.key}")
            end
          end
        end

        it "Every environment variable is prefixed in '#{name}'", action: name do
          prefix_map = {
            add_git_tag: 'FL_GIT_TAG',
            appetize_viewing_url_generator: 'APPETIZE',
            build_and_upload_to_appetize: 'APPETIZE',
            commit_version_bump: 'FL_VERSION_BUMP',
            create_keychain: 'KEYCHAIN',
            delete_keychain: 'KEYCHAIN',
            dotgpg_environment: 'DOTGPG',
            get_build_number: 'FL_BUILD_NUMBER',
            get_build_number_repository: 'FL_BUILD_NUMBER_REPO',
            get_info_plist_value: 'FL_GET_INFO_PLIST',
            get_version_number: 'FL_VERSION_NUMBER',
            hg_add_tag: 'FL_HG_TAG',
            hg_commit_version_bump: 'FL_VERSION_BUMP',
            onesignal: 'ONE_SIGNAL',
            push_git_tags: 'PUSH_GIT'
          }
          action.available_options.map(&:env_name).reject(&:nil?).each do |env_name|
            prefix = prefix_map[name.to_sym]
            if prefix.nil?
              prefix = name.upcase
              expect(env_name).to start_with(prefix).or start_with("FL_#{prefix}")
            else
              expect(env_name).to start_with(prefix)
            end
          end
        end
      end
    end
  end
end
