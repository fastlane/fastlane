require 'pty'

module Snapshot
  class Runner
    TRACE_DIR = '/tmp/snapshot_traces'

    def initialize
      Snapshot::DependencyChecker.check_dependencies
    end

    def work
      SnapshotConfig.shared_instance.js_file # to verify the file can be found

      Builder.new.build_app

      counter = 0
      SnapshotConfig.shared_instance.devices.each do |device|
        SnapshotConfig.shared_instance.languages.each do |language|

          begin
            run_tests(device, language)
            counter += copy_screenshots(language)
          rescue Exception => ex
            Helper.log.error(ex)
          end

        end
      end

      Helper.log.info "Successfully finished generating #{counter} screenshots.".green
      Helper.log.info "Check it out here: #{SnapshotConfig.shared_instance.screenshots_path}".green
    end

    def clean_old_traces
      FileUtils.rm_rf(TRACE_DIR)
      FileUtils.mkdir_p(TRACE_DIR)
    end


    def run_tests(device, language)
      Helper.log.info "Running tests on #{device} in language #{language}".green
      app_path = Dir.glob("/tmp/snapshot/build/*.app").first

      clean_old_traces

      ENV['SNAPSHOT_LANGUAGE'] = language
      command = generate_test_command(device, language, app_path)
      
      retry_run = false

      lines = []
      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          lines << line
          result = parse_test_line(line)

          case result
            when :retry
              retry_run = true
            when :screenshot
              Helper.log.info "Successfully took screenshot 📱"
            end
        end
      end

      if retry_run
        Helper.log.error "Instruments tool failed again. Re-trying..."
        sleep 2 # We need enough sleep... that's an instruments bug
        run_tests(device, language)
      end
    end

    def parse_test_line(line)
      if line =~ /.*Target failed to run.*/
        return :retry
      elsif line.include?"Screenshot captured"
        return :screenshot
      elsif line =~ /.*Error: (.*)/
        raise "UIAutomation Error: #{$1}"
      elsif line =~ /Instruments Usage Error :(.*)/
        raise "Instruments Usage Error: #{$1}"
      elsif line.include?"__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object"
        raise "Looks like something is wrong with the used app. Make sure the build was successful."
      end
    end

    def copy_screenshots(language)
      resulting_path = [SnapshotConfig.shared_instance.screenshots_path, language].join('/')
      resulting_path.gsub!("~", ENV['HOME']) # some strange bug requires this

      FileUtils.mkdir_p resulting_path

      Dir.glob("#{TRACE_DIR}/**/*.png") do |file|
        FileUtils.cp_r(file, resulting_path + '/')
      end
      return Dir.glob("#{TRACE_DIR}/**/*.png").count
    end

    def generate_test_command(device, language, app_path)
      script_path = SnapshotConfig.shared_instance.js_file

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