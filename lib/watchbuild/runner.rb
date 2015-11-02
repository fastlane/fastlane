require 'spaceship'

module WatchBuild
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to create or download a provisioning profile
    # returns the path the newly created provisioning profile (in /tmp usually)
    def run
      FastlaneCore::PrintTable.print_values(config: WatchBuild.config,
                                         hide_keys: [],
                                             title: "Summary for WatchBuild #{WatchBuild::VERSION}")

      Helper.log.info "Starting login with user '#{WatchBuild.config[:username]}'"
      Spaceship::Tunes.login(WatchBuild.config[:username], nil)
      Helper.log.info "Successfully logged in"

      build = wait_for_build
      notification(build)
    end

    def wait_for_build
      raise "Could not find app with app identiifer #{WatchBuild.config[:app_identifier]}".red unless app
      v = app.latest_version

      build = nil
      v.candidate_builds.each do |b|
        if !build or b.upload_date > build.upload_date
          build = b
        end
      end

      unless build
        Helper.log.fatal v.candidate_builds
        raise "Could not find build".red
      end

      loop do
        break if build.processing == false

        Helper.log.info "Waiting iTunes Connect processing... this might take a while..."
        if (Time.now - start) > (60 * 5)
          Helper.log.info ""
          Helper.log.info "You can tweet: \"iTunes Connect #iosprocessingtime #{((Time.now - start) / 60).round} minutes\""
        end
        sleep 30
      end

      return build
    end

    def notification(build)
      require 'terminal-notifier'

      url = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/#{@app.apple_id}/activity/ios/builds/#{build.train_version}/#{build.build_version}/details"
      TerminalNotifier.notify("Build finished processing",
                              title: build.app_name,
                           subtitle: "#{build.train_version} (#{build.build_version})",
                            execute: "open '#{url}'")
    end

    private

    def app
      @app ||= Spaceship::Application.find(WatchBuild.config[:app_identifier])
    end
  end
end
