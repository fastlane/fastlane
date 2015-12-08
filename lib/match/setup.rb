module Match
  class Setup
    def run(path)
      template = File.read("#{Helper.gem_path('match')}/lib/assets/MatchfileTemplate")

      UI.important "Please create a new, private git repository"
      UI.important "to store the certificates and profiles there"
      url = ask("URL of the Git Repo: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      UI.success "Successfully created '#{path}'. Open the file using a code editor."

      UI.important "You can now run `match development`, `match adhoc` and `fastlane appstore`"
      UI.info "On the first run for each environment it will create the provisioning profiles and"
      UI.info "certificates for you. From then on, it will automatically import the existing profiles."
      UI.info "For more information visit https://github.com/fastlane/match"
    end
  end
end
