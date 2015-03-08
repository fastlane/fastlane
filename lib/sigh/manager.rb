module Sigh
  class Manager
    def self.start
      path = Sigh::DeveloperCenter.new.run

      return nil unless path
      
      if Sigh.config[:filename]
        file_name = Sigh.config[:filename]
      else
        file_name = File.basename(path)
      end
      
      output = File.join(Sigh.config[:output_path].gsub("~", ENV["HOME"]), file_name)
      (FileUtils.mv(path, output) rescue nil) # in case it already exists
      system("open -g '#{output}'") unless Sigh.config[:skip_install]
      puts output.green

      return File.expand_path(output)      
    end
  end
end