module Fastfix
  class Setup
    def run(path)
      template = File.read("#{Helper.gem_path('fastfix')}/lib/assets/FixfileTemplate")

      Helper.log.info "Please create a new, private git repository".yellow
      Helper.log.info "to store the certificates and profiles there".yellow
      url = ask("URL: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      puts "Successfully created '#{path}'. Open the file using a code editor.".green
    end
  end
end
