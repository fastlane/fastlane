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

      UI.message("Starting login with user '#{WatchBuild.config[:username]}'")
      Spaceship::Tunes.login(WatchBuild.config[:username], nil)
      UI.message("Successfully logged in")

      start = Time.now
      sleep_time = 30 if WatchBuild.config[:sample_only_once] == false
      build = FastlaneCore::BuildWatcher.wait_for_build(app, WatchBuild.config[:platform], sleep_time)
      minutes = ((Time.now - start) / 60).round
      notification(build, minutes)
    end

    def notification(build, minutes)
      require 'terminal-notifier'

      if build.nil?
        UI.message "Application build is still processing"
        return
      end

      url = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/#{@app.apple_id}/activity/ios/builds/#{build.train_version}/#{build.build_version}/details"
      TerminalNotifier.notify("Build finished processing",
                              title: build.app_name,
                           subtitle: "#{build.train_version} (#{build.build_version})",
                            execute: "open '#{url}'")

      UI.success("Successfully finished processing the build")
      if minutes > 0 # it's 0 minutes if there was no new build uploaded
        UI.message("You can now tweet: ")
        UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
      end
      UI.message(url)
    end

    private

    def app
      @app ||= Spaceship::Application.find(WatchBuild.config[:app_identifier])
    end
  end
end
