require 'plist'

require_relative 'client_stubbing'
require_relative 'portal/portal_stubbing'
require_relative 'tunes/tunes_stubbing'
require_relative 'du/du_stubbing'

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

@cache_paths = [
  File.expand_path("/tmp/spaceship_itc_service_key.txt")
]

def try_delete(path)
  FileUtils.rm_f(path) if File.exist? path
end

def before_each_spaceship
  @cache_paths.each { |path| try_delete path }
  ENV["DELIVER_USER"] = "spaceship@krausefx.com"
  ENV["DELIVER_PASSWORD"] = "so_secret"
  ENV.delete("FASTLANE_USER")
end

def after_each_spaceship
  @cache_paths.each { |path| try_delete path }
end
