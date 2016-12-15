require 'erb'
require 'fastimage'

module Snapshot
  class ReportsGenerator
    def generate
      UI.message "Generating HTML Report"

      screens_path = Snapshot.config[:output_directory]

      @data = {}

      Dir[File.join(screens_path, "*")].sort.each do |language_folder|
        language = File.basename(language_folder)
        Dir[File.join(language_folder, '*.png')].sort.each do |screenshot|
          available_devices.each do |key_name, output_name|
            next unless File.basename(screenshot).include?(key_name)

            # This screenshot is from this device
            @data[language] ||= {}
            @data[language][output_name] ||= []

            resulting_path = File.join('.', language, File.basename(screenshot))
            @data[language][output_name] << resulting_path
            break # to not include iPhone 6 and 6 Plus (name is contained in the other name)
          end
        end
      end

      html_path = File.join(Snapshot::ROOT, "lib", "snapshot/page.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success "Successfully created HTML file with an overview of all the screenshots: '#{export_path}'"
      system("open '#{export_path}'") unless Snapshot.config[:skip_open_summary]
    end

    private

    def available_devices
      # The order IS important, since those names are used to check for include?
      # and the iPhone 6 is inlucded in the iPhone 6 Plus
      {
        'AppleTV1080p' => 'Apple TV',
        'iPhone7Plus' => "iPhone7Plus (5.5-Inch)",
        'iPhone7' => "iPhone7 (4.7-Inch)",
        'iPhone6sPlus' => "iPhone6sPlus (5.5-Inch)",
        'iPhone6Plus' => "iPhone6Plus (5.5-Inch)",
        'iPhone6s' => "iPhone6s (4.7-Inch)",
        'iPhone6' => "iPhone6 (4.7-Inch)",
        'iPhone5' => "iPhone5 (4-Inch)",
        'iPhone4' => "iPhone4 (3.5-Inch)",
        'iPadPro(9.7inch)' => "iPad Pro (9.7 inch)",
        'iPadPro(12.9inch)' => "iPad Pro (12.9 inch)",
        'iPad Pro' => "iPad Pro",
        'iPad' => "iPad",
        'Mac' => "Mac"
      }
    end
  end
end
