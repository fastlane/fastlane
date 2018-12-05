require_relative 'module'

module Screengrab
  class ReportsGenerator
    require 'erb'

    def generate
      UI.message("Generating HTML Report")

      screens_path = Screengrab.config[:output_directory]

      @data = {}

      Dir[File.join(screens_path, "*")].sort.each do |language_folder|
        language = File.basename(language_folder)
        Dir[File.join(language_folder, 'images', '*', '*.png')].sort.each do |screenshot|
          device_type_folder = File.basename(File.dirname(screenshot))
          @data[language] ||= {}
          @data[language][device_type_folder] ||= []
          resulting_path = File.join('.', language, 'images', device_type_folder, File.basename(screenshot))
          @data[language][device_type_folder] << resulting_path
        end
      end

      html_path = File.join(Screengrab::ROOT, "lib", "screengrab/page.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success("Successfully created HTML file with an overview of all the screenshots: '#{export_path}'")
      system("open '#{export_path}'") unless Screengrab.config[:skip_open_summary]
    end
  end
end
