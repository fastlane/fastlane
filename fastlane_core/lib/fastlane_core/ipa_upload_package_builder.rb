require 'digest/md5'

require_relative 'globals'
require_relative 'ui/ui'
require_relative 'module'

module FastlaneCore
  # Builds a package for the binary ready to be uploaded with the iTunes Transporter
  class IpaUploadPackageBuilder
    METADATA_FILE_NAME = 'metadata.xml'

    attr_accessor :package_path

    def generate(app_id: nil, ipa_path: nil, package_path: nil, platform: nil)
      self.package_path = File.join(package_path, "#{app_id}.itmsp")
      FileUtils.rm_rf(self.package_path) if File.directory?(self.package_path)
      FileUtils.mkdir_p(self.package_path)

      ipa_path = copy_ipa(ipa_path)
      @data = {
        apple_id: app_id,
        file_size: File.size(ipa_path),
        ipa_path: File.basename(ipa_path),
        md5:
          # this is only the base name as the ipa is inside the package
          Digest::MD5
            .file(ipa_path)
            .hexdigest,
        archive_type: 'bundle',
        platform: (platform || 'ios') # pass "appletvos" for Apple TV's IPA
      }

      xml_path = File.join(FastlaneCore::ROOT, 'lib/assets/XMLTemplate.xml.erb')
      xml = ERB.new(File.read(xml_path)).result(binding)

      File.write(File.join(self.package_path, METADATA_FILE_NAME), xml)
      if FastlaneCore::Globals.verbose?
        UI.success("Wrote XML data to '#{self.package_path}'")
      end

      return package_path
    end

    def unique_ipa_path(ipa_path)
      "#{Digest::SHA256.file(ipa_path).hexdigest}.ipa"
    end

    private

    def copy_ipa(ipa_path)
      ipa_file_name = unique_ipa_path(ipa_path)
      resulting_path = File.join(self.package_path, ipa_file_name)
      FileUtils.cp(ipa_path, resulting_path)

      return resulting_path
    end
  end
end
