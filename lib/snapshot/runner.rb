require 'pty'

module Snapshot
  class Runner
    BUILD_DIR = '/tmp/snapshot'
    TRACE_DIR = '/tmp/snapshot_traces'

    def initialize

    end

    def work
      devices = [
        "iPhone 6 (8.1 Simulator)",
        "iPhone 6 Plus (8.1 Simulator)",
        "iPhone 5 (8.1 Simulator)",
        "iPhone 4S (8.1 Simulator)"
      ]
      languages = [ 'de-DE', 'en-US' ]
      @ios_version = '8.1'
      @screenshots_path = './screenshots'

      find_project

      # Apparantly we have to do this twice: https://github.com/jonathanpenn/ui-screen-shooter/blob/master/ui-screen-shooter.sh#L111
      # build_app
      # build_app

      devices.each do |device|
        languages.each do |language|

          run_tests(device, language)
          copy_screenshots(language)

        end
      end
    end

    def clean_old_traces
      FileUtils.rm_rf(TRACE_DIR)
      FileUtils.mkdir_p(TRACE_DIR)
    end

    def find_project
      # TODO
      @project_path = Dir.glob("./integration/Moto\ Deals/*.xcworkspace").first
      @project_name = @project_path.split('/').last.split('.').first
    end

    def build_app
      command = generate_build_command
      Helper.log.warn command.green

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          Helper.log.debug line
          parse_build_line(line)
        end
      end
    end

    def parse_build_line(line)
      if line.include?"** BUILD FAILED **"
        raise line
      end
      # ** BUILD SUCCEEDED **
    end

    def run_tests(device, language)
      Helper.log.warn "Running tests on #{device} in language #{language}"
      app_path = Dir.glob("/tmp/snapshot/build/*.app").first

      clean_old_traces

      command = generate_test_command(device, language, app_path)
      
      retry_run = false

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          Helper.log.debug line
          result = parse_test_line(line)
          if result == :retry
            retry_run = true
          end
        end
      end

      if retry_run
        sleep 2 # We need enough sleep
        run_tests(device, language)
      end
    end

    def parse_test_line(line)
      if line =~ /.*Target failed to run.*/
        Helper.log.error "Instruments tool failed again. Re-trying..."
        return :retry
      elsif line.include?"__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object"
        raise "Looks like something is wrong with the used app. Make sure the build was successful."
      end
    end

    def copy_screenshots(language)
      resulting_path = [@screenshots_path, language].join('/')
      FileUtils.mkdir_p resulting_path
      Dir.glob("#{TRACE_DIR}/**/*.png") do |file|
        FileUtils.cp_r(file, resulting_path + '/')
      end
    end

    def generate_build_command
      scheme = @project_name # TODO

      [
        "xcodebuild",
        "-sdk iphonesimulator#{@ios_version}",
        "CONFIGURATION_BUILD_DIR='#{BUILD_DIR}/build'",
        "-workspace '#{@project_path}'",
        "-scheme '#{scheme}'",
        "-configuration Debug",
        "DSTROOT='#{BUILD_DIR}'",
        "OBJROOT='#{BUILD_DIR}'",
        "SYMROOT='#{BUILD_DIR}'",
        "ONLY_ACTIVE_ARCH=NO",
        "clean build"
      ].join(' ')
    end

    def generate_test_command(device, language, app_path)
      script_path = './test.js'

      [
        "instruments",
        "-w '#{device}'",
        "-D '#{TRACE_DIR}/trace'",
        "-t 'Automation'",
        "'#{app_path}'",
        "-e UIARESULTSPATH '#{TRACE_DIR}'",
        "-e UIASCRIPT '#{script_path}'",
        "-AppleLanguages '(#{language})'",
        "-AppleLocale '#{language}'" 
      ].join(' ')
    end
  end
end