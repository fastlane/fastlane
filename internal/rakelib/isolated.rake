# Runs the suite against a home directory the project controls, see fastlane#30184.
#
# The suite reads and writes the developer's real home. It leaves dozens of
# entries there — `~/.fastlane`, `~/Library/Logs/{fastlane,gym,scan,snapshot}`,
# `~/Library/MobileDevice/Provisioning Profiles`, `~/.appstoreconnect` and more
# — and it reads state left by earlier runs. That is how the itc_service_key
# dependency survived for months: `Client#itc_service_key` caches to a file, the
# examples depending on it passed on any machine that had ever run the suite,
# and only a clean CI checkout ever failed.
#
# Pointing HOME at a temporary directory makes those dependencies fail here
# rather than on someone else's machine.
#
#   rake test_isolated                 the whole suite
#   rake test_isolated[spaceship/spec] a subset
desc("Run the suite with HOME pointed at a throwaway directory")
task(:test_isolated, [:pattern]) do |_task, args|
  require "tmpdir"
  require "fileutils"

  home = Dir.mktmpdir("fastlane-isolated-home")
  env = { "HOME" => home }

  # A keychain has to be seeded, because `security cms -D`, which fastlane uses
  # to decode provisioning profiles in verify_build, provisioning_profile.rb and
  # sigh's local_manage, imports the signing certificate to verify the signature
  # and fails with "A default keychain could not be found" when there is none.
  # The certificates it writes land in this throwaway keychain instead of the
  # developer's login keychain, which is where they go today.
  if RUBY_PLATFORM.include?("darwin")
    FileUtils.mkdir_p(File.join(home, "Library", "Keychains"))
    keychain = "login.keychain"
    [
      "security create-keychain -p '' #{keychain}",
      "security default-keychain -s #{keychain}",
      "security list-keychains -s #{keychain}",
      "security unlock-keychain -p '' #{keychain}"
    ].each { |command| system(env, command, out: File::NULL, err: File::NULL) }

    # Check it took, and stop here if it did not. Running on without a keychain
    # is worse than a failure: with a desktop session `security` puts up a modal
    # asking for access and waits for someone to click it, so the suite hangs
    # rather than reporting anything. Headless there is nobody to click it.
    seeded = File.join(home, "Library", "Keychains", "#{keychain}-db")
    unless File.exist?(seeded)
      FileUtils.remove_entry(home)
      abort("could not seed a keychain at #{seeded}, refusing to run: the suite would block on a keychain prompt")
    end
    puts("HOME is #{home}, keychain seeded")
  else
    puts("HOME is #{home}")
  end

  command = args[:pattern] ? "rspec #{args[:pattern]} --format progress" : "rake test_all"
  ok = system(env, "bundle exec #{command}")

  # What the run left behind, which is the point of the exercise as much as the
  # pass or fail is.
  written = Dir.glob(File.join(home, "**", "*"), File::FNM_DOTMATCH)
               .select { |path| File.file?(path) }
  puts("")
  puts("The run wrote #{written.size} files into HOME:")
  written.group_by { |path| File.dirname(path).delete_prefix(home) }
         .sort_by { |directory, files| [-files.size, directory] }
         .each { |directory, files| puts("  #{files.size.to_s.rjust(4)}  ~#{directory}") }

  FileUtils.remove_entry(home)
  abort("suite failed under an isolated HOME") unless ok
end
