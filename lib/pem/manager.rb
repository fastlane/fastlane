module PEM
  # Creates the push profile and stores it in the correct location
  class Manager
    def self.start
      path, rsa_file = PEM::CertManager.new.run

      if path
        file_name = PEM.config[:pem_name] || File.basename(path)
        file_name =  file_name =~ /.pem/ ? file_name : "#{file_name}.pem"
        output = "./#{file_name}"
        FileUtils.mv(path, output)
        path = output
        puts output.green
      end
      
      if PEM.config[:save_private_key]
        file_name = File.basename(rsa_file)
        output = "./#{file_name}"
        FileUtils.mv(rsa_file, output)
        puts output.green          
      else
        File.delete(rsa_file) if rsa_file
      end

      return path
    end
  end
end