module Chiizu
  class Setup
    # This method will take care of creating a Chiizufile and other necessary files
    def self.create(path)
      chiizufile_path = File.join(path, 'Chiizufile')

      if File.exist?(chiizufile_path)
        raise "Chiizufile already exists at path '#{chiizufile_path}'. Run 'chiizu' to use chiizu.".red
      end

      gem_path = Helper.gem_path("chiizu")
      File.write(chiizufile_path, File.read("#{gem_path}/lib/assets/ChiizufileTemplate"))

      puts "Successfully created new Chiizufile at '#{chiizufile_path}'".green
    end
  end
end
