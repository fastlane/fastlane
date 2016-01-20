module Screengrab
  class Setup
    # This method will take care of creating a screengrabfile and other necessary files
    def self.create(path)
      screengrabfile_path = File.join(path, 'Screengrabfile')

      if File.exist?(screengrabfile_path)
        raise "Screengrabfile already exists at path '#{screengrabfile_path}'. Run 'screengrab' to use screengrab.".red
      end

      gem_path = Helper.gem_path("screengrab")
      File.write(screengrabfile_path, File.read("#{gem_path}/lib/assets/ScreengrabfileTemplate"))

      puts "Successfully created new Screengrabfile at '#{screengrabfile_path}'".green
    end
  end
end
