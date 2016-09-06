FastlaneCore::Feature.register(env_var: 'FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT',
                           description: 'Use iTunes Transporter shell script')
FastlaneCore::Feature.register(env_var: 'FASTLANE_USE_XCODEBUILD_CORE_DATA_WORKAROUND',
                           description: 'Work around a xcodebuild problem with Core Data projects: https://github.com/fastlane/fastlane/issues/5163')
