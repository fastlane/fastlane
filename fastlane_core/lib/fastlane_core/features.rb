require_relative 'feature/feature'

FastlaneCore::Feature.register(env_var: 'FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT',
                           description: 'Use iTunes Transporter shell script')
