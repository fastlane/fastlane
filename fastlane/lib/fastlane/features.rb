# Use this file as the place to register Feature switches for the fastlane_core project

# FastlaneCore::Feature.register(env_var: 'YOUR_FEATURE_SWITCH_ENV_VAR',
#                            description: 'Describe what this feature switch controls')

FastlaneCore::Feature.register(env_var: 'FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS',
                               description: 'Use a newly implemented screenshots synchronization logic')

FastlaneCore::Feature.register(env_var: 'FASTLANE_WWDR_USE_HTTP1_AND_RETRIES',
                               description: 'Adds --http1.1 and --retry 3 --retry-all-errors to the curl command to download WWDR certificates')
