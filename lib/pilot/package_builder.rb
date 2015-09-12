require "digest/md5"

module Pilot
  class PackageBuilder
    METADATA_FILE_NAME = "metadata.xml"

    attr_accessor :package_path

    def generate(apple_id: nil, ipa_path: nil, package_path: nil)
      self.package_path = File.join(package_path, "#{apple_id}.itmsp")
      FileUtils.rm_rf self.package_path if File.directory?(self.package_path)
      FileUtils.mkdir_p self.package_path

      lib_path = Helper.gem_path("pilot")

      ipa_path = copy_ipa(ipa_path)
      @data = {
        apple_id: apple_id,
        file_size: File.size(ipa_path),
        ipa_path: File.basename(ipa_path), # this is only the base name as the ipa is inside the package
        md5: Digest::MD5.hexdigest(File.read(ipa_path))
      }

      xml_path = File.join(lib_path, "lib/assets/XMLTemplate.xml.erb")
      xml = ERB.new(File.read(xml_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      File.write(File.join(self.package_path, METADATA_FILE_NAME), xml)
      Helper.log.info "Wrote XML data to '#{self.package_path}'".green if $verbose

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
