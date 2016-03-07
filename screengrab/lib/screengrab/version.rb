module Screengrab
  # In order to share the tool version info between Java and Ruby from one canonical file, we're
  # including version.properties in the bundled Gem, and deriving the version info from it here
  def self.determine_version
    version_props_file = File.join(File.dirname(__FILE__), '../../version.properties')

    # Java tends to write files as UTF-8, so we need to be resilent to the UTF-8 Byte Order Mark
    # being present
    File.open(version_props_file, 'r:bom|utf-8') do |f|
      v = {}

      # This file gets evaluated _before_ the gemspec gets built, we don't have access to loaded
      # 3rd party gems here! Thus, we'll do it simply, by hand.
      f.read.split("\n").each do |line|
        key, val = line.chomp.split('=')
        next if key.nil? || val.nil? || key.empty? || val.empty?
        v[key.strip] = val.strip
      end

      # The value of the block is returned from File.open
      [v['major'], v['minor'], v['patch']].join('.')
    end
  end

  VERSION = determine_version.freeze
  DESCRIPTION = "Automated localized screenshots of your Android app on every device".freeze
end
