require 'pty'
require 'shellwords'

module Snapshot
  class Runner

    attr_accessor :errors

    def work
      self.errors = []

      Helper.log.info "Building and running project - this might take some time...".green

      errors = []
      Snapshot.config[:devices].each do |device|
        Snapshot.config[:languages].each do |language|
          begin
            launch(language, device)
          rescue => ex
            errors << ex
          end
        end
      end

      raise errors.join('; ') if errors.count > 0
    end

    def launch(language, device_type)
      screenshots_path = "/tmp/snapshot/"
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)

      command = TestCommandGenerator.generate(device_type: device_type)

      Helper.log_alert("#{device_type.name} - #{language}")

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)

                                                # no exception raised... that means we need to retry
                                                launch(language, device_type)
                                              end)
    end


    # def generate_test_command(language, device_type)
    #   proj_path = Snapshot.config[:project_path]
    #   pre_command = Snapshot.config[:custom_args] || ENV["SNAPSHOT_CUSTOM_ARGS"] || ''
    #   custom_build_args = Snapshot.config[:custom_build_args] || ENV["SNAPSHOT_CUSTOM_BUILD_ARGS"] || ''
    #   build_command = pre_command + ' xcodebuild'
    #   actions = []
    #   # actions << 'clean' if clean
    #   actions << 'test'
    #   require 'pry'; binding.pry
    #   pipe = "| xcpretty" # TODO
    #   [
    #     build_command,
    #     "-sdk iphonesimulator",
    #     "-#{proj_key} '#{proj_path}'",
    #     "-scheme '#{Snapshot.config[:scheme]}'",
    #     "-destination 'platform=iOS Simulator,name=iPad 2,OS=#{Snapshot.config[:ios_version]}'",
    #     # "-AppleLanguages='(#{language})'",
    #     custom_build_args,
    #     actions.join(' '),
    #     pipe
    #   ].join(' ')
    # end
  end
end
