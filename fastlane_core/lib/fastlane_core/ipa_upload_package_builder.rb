require "digest/md5"

module FastlaneCore
  # Builds a package for the binary ready to be uploaded with the iTunes Transporter
  class IpaUploadPackageBuilder
    METADATA_FILE_NAME = "metadata.xml"

    attr_accessor :package_path

    def generate(app_id: nil, ipa_path: nil, package_path: nil, platform: nil)
      self.package_path = File.join(package_path, "#{app_id}.itmsp")
      FileUtils.rm_rf self.package_path if File.directory?(self.package_path)
      FileUtils.mkdir_p self.package_path

      ipa_path = copy_ipa(ipa_path)
      @data = {
        apple_id: app_id,
        file_size: File.size(ipa_path),
        ipa_path: File.basename(ipa_path), # this is only the base name as the ipa is inside the package
        md5: Digest::MD5.hexdigest(File.read(ipa_path)),
        archive_type: "bundle",
        platform: (platform || "ios") # pass "appletvos" for Apple TV's IPA
      }

      xml_path = File.join(FastlaneCore::ROOT, "lib/assets/XMLTemplate.xml.erb")
      xml = ERB.new(File.read(xml_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      File.write(File.join(self.package_path, METADATA_FILE_NAME), xml)
      UI.success("Wrote XML data to '#{self.package_path}'") if $verbose

      return package_path
    end

    private

    def copy_ipa(ipa_path)
      ipa_file_name = Digest::MD5.hexdigest(ipa_path)
      resulting_path = File.join(self.package_path, "#{ipa_file_name}.ipa")
      FileUtils.cp(ipa_path, resulting_path)

      return resulting_path
    end
  end
end
