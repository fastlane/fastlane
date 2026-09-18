# Runs the suite against a home and a temporary directory the project controls,
# see fastlane#30184.
#
# The suite reads and writes both. It leaves dozens of entries in the home
# directory — `~/.fastlane`, `~/Library/Logs/{fastlane,gym,scan,snapshot}`,
# `~/Library/MobileDevice/Provisioning Profiles`, `~/.appstoreconnect` and more
# — and it reads state left by earlier runs in either place.
#
# Both matter, and the second is easy to forget. `Client#itc_service_key` caches
# the App Store Connect key under the temporary directory, not the home one, so
# examples depending on that cache pass on any machine that has run the suite
# before and fail only on a clean checkout. Isolating HOME alone leaves that
# whole class invisible, which it was until it broke CI.
#
# Pointing both at throwaway directories makes those dependencies fail here
# rather than on someone else's machine.
#
#   rake test_isolated                 the whole suite
#   rake test_isolated[spaceship/spec] a subset
desc("Run the suite with HOME and TMPDIR pointed at throwaway directories")
task(:test_isolated, [:pattern]) do |_task, args|
  require "tmpdir"
  require "fileutils"

  home = Dir.mktmpdir("fastlane-isolated-home")
  # Made before TMPDIR is redirected, so both live somewhere real.
  tmp = Dir.mktmpdir("fastlane-isolated-tmp")
  env = { "HOME" => home, "TMPDIR" => tmp }

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
  { "HOME" => home, "TMPDIR" => tmp }.each do |name, root|
    written = Dir.glob(File.join(root, "**", "*"), File::FNM_DOTMATCH)
                 .select { |path| File.file?(path) }
    puts("")
    puts("The run wrote #{written.size} files into #{name}:")
    prefix = name == "HOME" ? "~" : ""
    written.group_by { |path| File.dirname(path).delete_prefix(root) }
           .sort_by { |directory, files| [-files.size, directory] }
           .each do |directory, files|
             # Files sitting at the root group under an empty string, and the
             # ones that land there are usually the interesting ones.
             label = directory.empty? ? files.map { |f| File.basename(f) }.sort.join(", ") : "#{prefix}#{directory}"
             puts("  #{files.size.to_s.rjust(4)}  #{label}")
           end
  end

  [home, tmp].each { |root| FileUtils.remove_entry(root) }
  abort("suite failed under an isolated HOME and TMPDIR") unless ok
end
