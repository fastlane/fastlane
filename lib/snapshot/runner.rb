require 'pty'

module Snapshot
  class Runner
    TRACE_DIR = '/tmp/snapshot_traces'

    def initialize

    end

    def work
      @screenshots_path = './screenshots'

      Builder.new.build_app

      SnapshotConfig.shared_instance.devices.each do |device|
        SnapshotConfig.shared_instance.languages.each do |language|

          run_tests(device, language)
          copy_screenshots(language)

        end
      end
    end

    def clean_old_traces
      FileUtils.rm_rf(TRACE_DIR)
      FileUtils.mkdir_p(TRACE_DIR)
    end


    def run_tests(device, language)
      Helper.log.warn "Running tests on #{device} in language #{language}"
      app_path = Dir.glob("/tmp/snapshot/build/*.app").first

      clean_old_traces

      command = generate_test_command(device, language, app_path)
      
      retry_run = false

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          if line.length > 1
            result = parse_test_line(line)
            if result == :retry
              retry_run = true
            end
          end
        end
      end

      if retry_run
        sleep 2 # We need enough sleep
        run_tests(device, language)
      end
    end

    def parse_test_line(line)
      Helper.log.debug line

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