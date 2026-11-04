require 'tmpdir'

describe Fastlane do
  describe Fastlane::Actions::SpaceshipLogsAction do
    # This action reads the files Spaceship::Client#logger writes. The two used
    # to agree on a literal "/tmp" and now agree on Dir.tmpdir, which is a thing
    # they can only get wrong together. Moving one without the other leaves the
    # action silently finding nothing. See fastlane#30184.
    it "looks where spaceship writes its logs" do
      path = File.join(Dir.tmpdir, "spaceship#{Time.now.to_i}_#{Process.pid}_spec.log")
      File.write(path, "a log line")

      begin
        files = Fastlane::Actions::SpaceshipLogsAction.run(
          latest: false,
          print_contents: false,
          print_paths: false,
          copy_to_path: nil,
          copy_to_clipboard: false
        )

        expect(files).to include(path)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
