require 'zip'

module FastlaneCore
  class IpaFileAnalyser

    # Fetches the app identifier (e.g. com.facebook.Facebook) from the given ipa file.
    def self.fetch_app_identifier(path)
      plist = IpaFileAnalyser.fetch_info_plist_file(path)
      return plist['CFBundleIdentifier'] if plist
      return nil
    end

    # Fetches the app version from the given ipa file.
    def self.fetch_app_version(path)
      plist = IpaFileAnalyser.fetch_info_plist_file(path)
      return plist['CFBundleShortVersionString'] if plist
      return nil
    end

    def self.fetch_info_plist_file(path)
      Zip::File.open(path) do |zipfile|
        zipfile.each do |file|
          if file.name.include?'.plist' and not ['.bundle', '.framework'].any? { |a| file.name.include?a }
            # We can not be completely sure, that's the correct plist file, so we have to try
            begin
              # The XML file has to be properly unpacked first
              tmp_path = "/tmp/deploytmp.plist"
              File.write(tmp_path, zipfile.read(file))
              system("plutil -convert xml1 #{tmp_path}")
              result = Plist::parse_xml(tmp_path)
              File.delete(tmp_path)

              if result['CFBundleIdentifier'] or result['CFBundleVersion']
                return result
              end
            rescue
              # We don't really care, look for another XML file
            end
          end
        end
      end

      nil
    end
  end
end