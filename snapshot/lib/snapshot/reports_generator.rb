require 'erb'
require 'fastimage'

module Snapshot
  class ReportsGenerator
    def generate
      UI.message "Generating HTML Report"

      screens_path = File.join(Snapshot.config[:output_directory], "screenshots")

      @data = {}

      Dir[File.join(screens_path, "*")].sort.select {|f| File.directory? f}.each do |language_folder|
        language = File.basename(language_folder)
        @data[language] ||= {}

        Dir[File.join(language_folder, "*")].sort.select {|f| File.directory? f}.each do |device_folder|
          device = File.basename(device_folder)
          @data[language][device] ||= {}

          Dir[File.join(device_folder, "*"), device_folder].sort.select {|f| File.directory? f}.each do |section_folder|
            section = section_folder == device_folder ? "$undefined" : File.basename(section_folder)

            screenshots = Dir[File.join(section_folder, '*.png')].sort
            screenshots.each do |screenshot|
              @data[language][device][section] ||= []
              screenshot_name = File.basename(screenshot)
              if section_folder == device_folder || section == "$undefined"
                resulting_path = File.join('.', "screenshots", language, device, File.basename(screenshot))
              else
                resulting_path = File.join('.', "screenshots", language, device, section, File.basename(screenshot))
              end
              @data[language][device][section] << resulting_path
            end
          end
        end
      end

      html_path = File.join(lib_path, "snapshot/page.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = File.join(Snapshot.config[:output_directory],"screenshots.html")
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success "Successfully created HTML file with an overview of all the screenshots: '#{export_path}'"
      system("open '#{export_path}'") unless Snapshot.config[:skip_open_summary]
    end

    private

    def lib_path
      if !Helper.is_test? and Gem::Specification.find_all_by_name('snapshot').any?
        return [Gem::Specification.find_by_name('snapshot').gem_dir, 'lib'].join('/')
      else
        return './lib'
      end
    end

    # returns the output name for a device
    # if the output name could not be found, it returns the input parameter "device"
    def device_output_name(device)
          available_devices.each do |key_name, output_name|
            next unless device.include?(key_name)
            return output_name
          end
          return device
    end

    def available_devices
      # The order IS important, since those names are used to check for include?
      # and the iPhone 6 is inlucded in the iPhone 6 Plus
      {
        'iPhone6sPlus' => "5.5-Inch",
        'iPhone6Plus' => "5.5-Inch",
        'iPhone6s' => "4.7-Inch",
        'iPhone6' => "4.7-Inch",
        'iPhone5' => "4-Inch",
        'iPhone4' => "3.5-Inch",
        'iPadPro' => "iPad Pro",
        'iPad' => "iPad",
        'Mac' => "Mac"
      }
    end
  end
end
