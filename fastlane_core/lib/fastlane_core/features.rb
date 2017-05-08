FastlaneCore::Feature.register(env_var: 'FASTLANE_SNAPSHOT_BUILD_FOR_TESTING',
                           description: 'Use Build-For-Testing instead of build on every device used in snapshot')
FastlaneCore::Feature.register(env_var: 'FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT',
                           description: 'Use iTunes Transporter shell script')
