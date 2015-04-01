require 'pty'
require 'shellwords'

module Snapshot
  class Runner
    TRACE_DIR = '/tmp/snapshot_traces'

    def work(clean: true, build: true)
      SnapshotConfig.shared_instance.js_file # to verify the file can be found earlier

      Builder.new.build_app(clean: clean) if build
      @app_path = determine_app_path

      counter = 0
      errors = []

      FileUtils.rm_rf SnapshotConfig.shared_instance.screenshots_path if SnapshotConfig.shared_instance.clear_previous_screenshots

      SnapshotConfig.shared_instance.devices.each do |device|
        SnapshotConfig.shared_instance.languages.each do |language|
          reinstall_app(device, language) unless ENV["SNAPSHOT_SKIP_UNINSTALL"]

          prepare_simulator(device, language)
          
          begin
            errors.concat(run_tests(device, language))
            counter += copy_screenshots(language)
          rescue => ex
            Helper.log.error(ex)
          end

          teardown_simulator(device, language)
        end
      end

      `killall "iOS Simulator"` # close the simulator after the script is finished

      ReportsGenerator.new.generate

      if errors.count > 0
        Helper.log.error "-----------------------------------------------------------"
        Helper.log.error errors.join(' - ').red
        Helper.log.error "-----------------------------------------------------------"
        raise "Finished generating #{counter} screenshots with #{errors.count} errors.".red
      else
        Helper.log.info "Successfully finished generating #{counter} screenshots.".green
      end
      
      Helper.log.info "Check it out here: #{SnapshotConfig.shared_instance.screenshots_path}".green
    end

    def clean_old_traces
      FileUtils.rm_rf(TRACE_DIR)
      FileUtils.mkdir_p(TRACE_DIR)
    end

    def prepare_simulator(device, language)
      SnapshotConfig.shared_instance.blocks[:setup_for_device_change].call(device, udid_for_simulator(device), language)  # Callback
      SnapshotConfig.shared_instance.blocks[:setup_for_language_change].call(language, device) # deprecated
    end

    def teardown_simulator(device, language)
      SnapshotConfig.shared_instance.blocks[:teardown_language].call(language, device) # Callback
      SnapshotConfig.shared_instance.blocks[:teardown_device].call(device, language) # deprecated
    end

    def udid_for_simulator(name) # fetches the UDID of the simulator type
      all = `instruments -s`.split("\n")
      all.each do |current|
        return current.match(/\[(.*)\]/)[1] if current.include?name
      end
      raise "Could not find simulator '#{name}' to install the app on."
    end

    def reinstall_app(device, language)

      app_identifier = ENV["SNAPSHOT_APP_IDENTIFIER"]
      app_identifier ||= @app_identifier

      def com(cmd)
        puts cmd.magenta
        result = `#{cmd}`
        puts result if result.to_s.length > 0
      end

      udid = udid_for_simulator(device)


      com("killall 'iOS Simulator'")
      sleep 3
      com("xcrun simctl boot '#{udid}'")
      com("xcrun simctl uninstall booted '#{app_identifier}'")
      sleep 3
      com("xcrun simctl install booted '#{@app_path.shellescape}'")
      com("xcrun simctl shutdown booted")
    end

    def run_tests(device, language)
      Helper.log.info "Running tests on #{device} in language #{language}".green

      clean_old_traces

      ENV['SNAPSHOT_LANGUAGE'] = language
      command = generate_test_command(device, language)
      Helper.log.debug command.yellow
      
      retry_run = false

      lines = []
      errors = []
      PTY.spawn(command) do |stdout, stdin, pid|

        # Waits for process so that we can see if anything has failed
        begin
          stdout.sync

          stdout.each do |line|
            lines << line
            begin
              puts line.strip if $verbose
              result = parse_test_line(line)
              case result
                when :retry
                  retry_run = true
                when :screenshot
                  Helper.log.info "Successfully took screenshot 📱"
                when :need_permission
                  raise "Looks like you may need to grant permission for Instruments to analyze other processes.\nPlease Ctrc + C and run this command: \"#{command}\""
                end
            rescue Exception => ex
              Helper.log.error lines.join('')
              Helper.log.error ex.to_s.red
              errors << ex.to_s
            end
          end

        rescue Errno::EIO => e
          # We could maybe do something like this
        ensure
          ::Process.wait pid
        end

      end

      if retry_run
        Helper.log.error "Instruments tool failed again. Re-trying..."
        sleep 2 # We need enough sleep... that's an instruments bug
        errors = run_tests(device, language)
      end

      return errors
    end

    def determine_app_path
      # Determine the path to the actual app and not the WatchKit app
      Dir.glob("/tmp/snapshot/build/*.app/*.plist").each do |path|
        watchkit_enabled = `/usr/libexec/PlistBuddy -c 'Print WKWatchKitApp' '#{path}'`.strip
        next if watchkit_enabled == 'true' # we don't care about WatchKit Apps

        app_identifier = `/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' '#{path}'`.strip
        if app_identifier and app_identifier.length > 0
          # This seems to be the valid Info.plist
          @app_identifier = app_identifier
          return File.expand_path("..", path) # the app
        end
      end
    end

    def parse_test_line(line)
      if line =~ /.*Target failed to run.*/
        return :retry
      elsif line.include?"Screenshot captured"
        return :screenshot
      elsif line.include? "Instruments wants permission to analyze other processes"
        return :need_permission
      elsif line =~ /.*Error: (.*)/
        raise "UIAutomation Error: #{$1}"
      elsif line =~ /Instruments Usage Error :(.*)/
        raise "Instruments Usage Error: #{$1}"
      elsif line.include?"__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object"
        raise "Looks like something is wrong with the used app. Make sure the build was successful."
      end
    end

    def copy_screenshots(language)
      resulting_path = File.join(SnapshotConfig.shared_instance.screenshots_path, language)

      FileUtils.mkdir_p resulting_path

      unless SnapshotConfig.shared_instance.skip_alpha_removal
        ScreenshotFlatten.new.run(TRACE_DIR)
      end

      ScreenshotRotate.new.run(TRACE_DIR)

      Dir.glob("#{TRACE_DIR}/**/*.png") do |file|
        FileUtils.cp_r(file, resulting_path + '/')
      end
      return Dir.glob("#{TRACE_DIR}/**/*.png").count
    end

    def generate_test_command(device, language)
      is_ipad = (device.downcase.include?'ipad')
      script_path = SnapshotConfig.shared_instance.js_file(is_ipad)

      [
        "instruments",
        "-w '#{device}'",
        "-D '#{TRACE_DIR}/trace'",
        "-t 'Automation'",
        "#{@app_path.shellescape}",
        "-e UIARESULTSPATH '#{TRACE_DIR}'",
        "-e UIASCRIPT '#{script_path}'",
        "-AppleLanguages '(#{language})'",
        "-AppleLocale '#{language}'" 
      ].join(' ')
    end
  end
end
