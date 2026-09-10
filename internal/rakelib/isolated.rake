# Runs the suite against a home directory the project controls, see fastlane#30184.
#
# The suite reads and writes the developer's real home. It leaves 53 entries
# there, `~/.fastlane`, `~/Library/Logs/{fastlane,gym,scan,snapshot}`,
# `~/Library/MobileDevice/Provisioning Profiles`, `~/.appstoreconnect` and more,
# and it reads state left by earlier runs. That is how row Z survived for
# months: `Client#itc_service_key` cached to a file, the examples depending on
# it passed on any machine that had ever run the suite, and only a clean CI
# checkout ever failed.
#
# Pointing HOME at a temporary directory makes those dependencies fail here
# rather than on someone else's machine.
#
#   rake test_isolated                 the whole suite, one process
#   WORKERS=12 rake test_isolated      the whole suite, split
#   rake test_isolated[spaceship/spec] a subset
#
# A keychain has to be seeded, because `security cms -D`, which fastlane uses to
# decode provisioning profiles in verify_build, provisioning_profile.rb and
# sigh's local_manage, imports the signing certificate to verify the signature
# and fails with "A default keychain could not be found" when there is none. The
# certificates it writes land in this throwaway keychain instead of the
# developer's login keychain, which is where four of them go today.
desc("Run the suite with HOME pointed at a throwaway directory")
task(:test_isolated, [:pattern]) do |_task, args|
  require "tmpdir"
  require "fileutils"

  home = Dir.mktmpdir("fastlane-isolated-home")
  FileUtils.mkdir_p(File.join(home, "Library", "Keychains"))

  env = { "HOME" => home }
  keychain = "login.keychain"
  [
    "security create-keychain -p '' #{keychain}",
    "security default-keychain -s #{keychain}",
    "security list-keychains -s #{keychain}",
    "security unlock-keychain -p '' #{keychain}"
  ].each { |command| system(env, command, out: File::NULL, err: File::NULL) }

  puts("HOME is #{home}")

  target = ENV["WORKERS"] ? "test_parallel" : "test_all"
  target = "spec" if args[:pattern]
  command =
    if args[:pattern]
      "rspec #{args[:pattern]} --format progress"
    else
      "rake #{target}"
    end

  ok = system(env, "bundle exec #{command}")

  # What the run left behind, which is the point of the exercise as much as the
  # pass or fail is.
  written = Dir.glob(File.join(home, "**", "*"), File::FNM_DOTMATCH)
               .reject { |path| File.basename(path).start_with?(".", "..") && File.directory?(path) }
  puts("")
  puts("The run wrote #{written.size} entries into HOME:")
  written.select { |path| File.file?(path) }.first(15).each do |path|
    puts("  ~#{path.delete_prefix(home)}")
  end

  FileUtils.remove_entry(home)
  abort("suite failed under an isolated HOME") unless ok
end
