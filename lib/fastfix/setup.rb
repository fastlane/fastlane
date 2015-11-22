module Fastfix
  class Setup
    def run(path)
      template = File.read("#{Helper.gem_path('fastfix')}/lib/assets/FixfileTemplate")

      Helper.log.info "Please create a new, private git repository".yellow
      Helper.log.info "to store the certificates and profiles there".yellow
      url = ask("URL of the Git Repo: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      puts "Successfully created '#{path}'. Open the file using a code editor.".green

      puts "You can now run `fastfix development`, `fastfix adhoc` and `fastlane appstore`"
      puts "On the first run for each environment it will create the provisioning profiles and"
      puts "certificates for you. From then on, it will automatically import the existing profiles."
    end
  end
end
