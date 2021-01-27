require 'open3'
require 'zip'

require_relative 'core_ext/cfpropertylist'
require_relative 'ui/ui'

module FastlaneCore
  class IpaFileAnalyser
    # Fetches the app identifier (e.g. com.facebook.Facebook) from the given ipa file.
    def self.fetch_app_identifier(path)
      plist = self.fetch_info_plist_file(path)
      return plist['CFBundleIdentifier'] if plist
      return nil
    end

    # Fetches the app version from the given ipa file.
    def self.fetch_app_version(path)
      plist = self.fetch_info_plist_file(path)
      return plist['CFBundleShortVersionString'] if plist
      return nil
    end

    # Fetches the app build number from the given ipa file.
    def self.fetch_app_build(path)
      plist = self.fetch_info_plist_file(path)
      return plist['CFBundleVersion'] if plist
      return nil
    end

    # Fetches the app platform from the given ipa file.
    def self.fetch_app_platform(path)
      plist = self.fetch_info_plist_file(path)
      platform = "ios"
      platform = plist['DTPlatformName'] if plist
      platform = "ios" if platform == "iphoneos" # via https://github.com/fastlane/fastlane/issues/3484
      return platform
    end

    def self.fetch_info_plist_file(path)
      UI.user_error!("Could not find file at path '#{path}'") unless File.exist?(path)
      plist_data = self.fetch_info_plist_with_rubyzip(path)
      if plist_data.nil?
        # Xcode produces invalid zip files for IPAs larger than 4GB. RubyZip
        # can't read them, but the unzip command is able to work around this.
        plist_data = self.fetch_info_plist_with_unzip(path)
      end
      return nil if plist_data.nil?

      # Creates a temporary directory with a unique name tagged with 'fastlane'
      # The directory is deleted automatically at the end of the block
      Dir.mktmpdir("fastlane") do |tmp|
        # The XML file has to be properly unpacked first
        tmp_path = File.join(tmp, "Info.plist")
        File.open(tmp_path, 'wb') do |output|
          output.write(plist_data)
        end
        result = CFPropertyList.native_types(CFPropertyList::List.new(file: tmp_path).value)

        if result['CFBundleIdentifier'] || result['CFBundleVersion']
          return result
        end
      end

      return nil
    end

    def self.fetch_info_plist_with_rubyzip(path)
      Zip::File.open(path, "rb") do |zipfile|
        file = zipfile.glob('**/Payload/*.app/Info.plist').first
        return nil unless file
        zipfile.read(file)
      end
    end

    def self.fetch_info_plist_with_unzip(path)
      list, error, = Open3.capture3("unzip", "-Z", "-1", path)
      UI.command_output(error) unless error.empty?
      return nil if list.empty?
      entry = list.chomp.split("\n").find do |e|
        File.fnmatch("**/Payload/*.app/Info.plist", e, File::FNM_PATHNAME)
      end
      data, error, = Open3.capture3("unzip", "-p", path, entry)
      UI.command_output(error) unless error.empty?
      return nil if data.empty?
      data
    end
  end
end
