module Screengrab
  class Setup
    # This method will take care of creating a screengrabfile and other necessary files
    def self.create(path)
      screengrabfile_path = File.join(path, 'Screengrabfile')

      if File.exist?(screengrabfile_path)
        UI.user_error!("Screengrabfile already exists at path '#{screengrabfile_path}'. Run 'screengrab' to use screengrab.")
      end

      File.write(screengrabfile_path, File.read("#{Screengrab::ROOT}/lib/assets/ScreengrabfileTemplate"))

      UI.success("Successfully created new Screengrabfile at '#{screengrabfile_path}'")
    end
  end
end
