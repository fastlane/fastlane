require_relative 'module'
require_relative 'storage'

module Match
  class Setup
    def run(path, is_swift_fastfile: false)
      if is_swift_fastfile
        template = File.read("#{Match::ROOT}/lib/assets/MatchfileTemplate.swift")
      else
        template = File.read("#{Match::ROOT}/lib/assets/MatchfileTemplate")
      end

      storage_mode = UI.select(
        "fastlane match supports multiple storage modes, please select the one you want to use:",
        self.storage_options
      )

      storage = Storage.for_mode(storage_mode, {})

      specific_content = storage.generate_matchfile_content
      UI.crash!("Looks like `generate_matchfile_content` was `nil` for `#{storage_mode}`") if specific_content.nil?
      specific_content += "\n\n" if specific_content.length > 0
      specific_content += "storage_mode(\"#{storage_mode}\")"

      template.gsub!("[[CONTENT]]", specific_content)

      File.write(path, template)
      UI.success("Successfully created '#{path}'. You can open the file using a code editor.")

      UI.important("You can now run `fastlane match development`, `fastlane match adhoc`, `fastlane match enterprise` and `fastlane match appstore`")
      UI.message("On the first run for each environment it will create the provisioning profiles and")
      UI.message("certificates for you. From then on, it will automatically import the existing profiles.")
      UI.message("For more information visit https://docs.fastlane.tools/actions/match/")
    end

    def storage_options
      return ["git", "google_cloud", "s3"]
    end
  end
end
