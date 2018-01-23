require_relative 'module'

module Match
  class Setup
    def run(path, is_swift_fastfile: false)
      if is_swift_fastfile
        template = File.read("#{Match::ROOT}/lib/assets/MatchfileTemplate.swift")
      else
        template = File.read("#{Match::ROOT}/lib/assets/MatchfileTemplate")
      end

      UI.important("Please create a new, private git repository")
      UI.important("to store the certificates and profiles there")
      url = UI.input("URL of the Git Repo: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      UI.success("Successfully created '#{path}'. You can open the file using a code editor.")

      UI.important("You can now run `fastlane match development`, `fastlane match adhoc`, `fastlane match enterprise` and `fastlane match appstore`")
      UI.message("On the first run for each environment it will create the provisioning profiles and")
      UI.message("certificates for you. From then on, it will automatically import the existing profiles.")
      UI.message("For more information visit https://docs.fastlane.tools/actions/match/")
    end
  end
end
