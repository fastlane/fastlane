module Fastlane
  module Actions
    class AppiumAction < Action
      INVOKE_TIMEOUT = 30
      APPIUM_PATH_HOMEBREW = '/usr/local/bin/appium'
      APPIUM_APP_PATH = '/Applications/Appium.app'
      APPIUM_APP_BUNDLE_PATH = 'Contents/Resources/node_modules/.bin/appium'

      def self.run(params)
        Actions.verify_gem!('rspec')
        Actions.verify_gem!('appium_lib')

        require 'rspec'
        require 'appium_lib' unless Helper.test?

        FastlaneCore::PrintTable.print_values(
          config: params,
          title: "Summary for Appium Action"
        )

        if params[:invoke_appium_server]
          appium_pid = invoke_appium_server(params)
          wait_for_appium_server(params)
        end

        configure_rspec(params)

        rspec_args = []
        rspec_args << params[:spec_path]
        status = RSpec::Core::Runner.run(rspec_args).to_i
        if status != 0
          UI.user_error!("Failed to run Appium spec. status code: #{status}")
        end
      ensure
        Actions.sh("kill #{appium_pid}") if appium_pid
      end

      def self.invoke_appium_server(params)
        appium = detect_appium(params)
        Process.spawn("#{appium} -a #{params[:host]} -p #{params[:port]}")
      end

      def self.detect_appium(params)
        appium_path = params[:appium_path] || `which appium`.to_s.strip

        if appium_path.empty?
          if File.exist?(APPIUM_PATH_HOMEBREW)
            appium_path = APPIUM_PATH_HOMEBREW
          elsif File.exist?(APPIUM_APP_PATH)
            appium_path = APPIUM_APP_PATH
          end
        end

        unless File.exist?(appium_path)
          UI.user_error!("You have to install Appium using `npm install -g appium`")
        end

        if appium_path.end_with?('.app')
          appium_path = "#{appium_path}/#{APPIUM_APP_BUNDLE_PATH}"
        end

        UI.message("Appium executable detected: #{appium_path}")
        appium_path
      end

      def self.wait_for_appium_server(params)
        loop.with_index do |_, count|
          break if `lsof -i:#{params[:port]}`.to_s.length != 0

          if count * 5 > INVOKE_TIMEOUT
            UI.user_error!("Invoke Appium server timed out")
          end
          sleep(5)
        end
      end

      def self.configure_rspec(params)
        RSpec.configure do |c|
          c.before(:each) do
            caps = params[:caps] || {}
            caps[:platformName] ||= params[:platform]
            caps[:autoAcceptAlerts] ||= true
            caps[:app] = params[:app_path]

            appium_lib = params[:appium_lib] || {}

            @driver = Appium::Driver.new(
              caps: caps,
              server_url: params[:host],
              port: params[:port],
              appium_lib: appium_lib
            ).start_driver
            Appium.promote_appium_methods(RSpec::Core::ExampleGroup)
          end

          c.after(:each) do
            @driver.quit unless @driver.nil?
          end
        end
      end

      def self.description
        'Run UI test by Appium with RSpec'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: 'FL_APPIUM_PLATFORM',
                                       description: 'Appium platform name'),
          FastlaneCore::ConfigItem.new(key: :spec_path,
                                       env_name: 'FL_APPIUM_SPEC_PATH',
                                       description: 'Path to Appium spec directory'),
          FastlaneCore::ConfigItem.new(key: :app_path,
                                       env_name: 'FL_APPIUM_APP_FILE_PATH',
                                       description: 'Path to Appium target app file'),
          FastlaneCore::ConfigItem.new(key: :invoke_appium_server,
                                       env_name: 'FL_APPIUM_INVOKE_APPIUM_SERVER',
                                       description: 'Use local Appium server with invoke automatically',
                                       type: Boolean,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :host,
                                       env_name: 'FL_APPIUM_HOST',
                                       description: 'Hostname of Appium server',
                                       default_value: '0.0.0.0',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :port,
                                       env_name: 'FL_APPIUM_PORT',
                                       description: 'HTTP port of Appium server',
                                       type: Integer,
                                       default_value: 4723,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :appium_path,
                                       env_name: 'FL_APPIUM_EXECUTABLE_PATH',
                                       description: 'Path to Appium executable',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :caps,
                                       env_name: 'FL_APPIUM_CAPS',
                                       description: 'Hash of caps for Appium::Driver',
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :appium_lib,
                                       env_name: 'FL_APPIUM_LIB',
                                       description: 'Hash of appium_lib for Appium::Driver',
                                       type: Hash,
                                       optional: true)
        ]
      end

      def self.author
        'yonekawa'
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.category
        :testing
      end

      def self.example_code
        [
          'appium(
            app_path:  "appium/apps/TargetApp.app",
            spec_path: "appium/spec",
            platform:  "iOS",
            caps: {
              versionNumber: "9.1",
              deviceName:    "iPhone 6"
            },
            appium_lib: {
              wait: 10
            }
          )'
        ]
      end
    end
  end
end
