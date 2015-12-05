module Match
  class Setup
    def run(path)
      template = File.read("#{Helper.gem_path('match')}/lib/assets/MatchfileTemplate")

      Helper.log.info "Please create a new, private git repository".yellow
      Helper.log.info "to store the certificates and profiles there".yellow
      url = ask("URL of the Git Repo: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      puts "Successfully created '#{path}'. Open the file using a code editor.".green

      puts "You can now run `match development`, `match adhoc` and `fastlane appstore`"
      puts "On the first run for each environment it will create the provisioning profiles and"
      puts "certificates for you. From then on, it will automatically import the existing profiles."
      puts "For more information visit https://github.com/fastlane/match"
    end
  end
end
