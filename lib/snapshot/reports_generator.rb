require 'erb'
require 'fastimage'

module Snapshot
  class ReportsGenerator
    def generate

      config = SnapshotConfig.shared_instance
      screens_path = config.screenshots_path

      @title = config.html_title    
      @data = {}

      Dir["#{screens_path}/*"].sort.each do |language_path|
        language = File.basename(language_path)
        Dir[File.join(language_path, '*')].sort.each do |screenshot|

          ["portrait", "landscape"].each do |orientation|
            available_devices.each do |key_name, output_name|
              if File.basename(screenshot).include?key_name and File.basename(screenshot).include?orientation
                output_name += " (#{orientation.capitalize})"
                # This screenshot it from this device
                @data[language] ||= {}
                @data[language][output_name] ||= []

                resulting_path = File.join('.', language, File.basename(screenshot))
                @data[language][output_name] << resulting_path
                break # to not include iPhone 6 and 6 Plus (name is contained in the other name)
              end
            end
          end
        end
      end

      html_path = File.join(lib_path, "snapshot/page.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      Helper.log.info "Successfully created HTML file with an overview of all the screenshots: '#{export_path}'".green
      system("open '#{export_path}'") unless ENV["SNAPSHOT_SKIP_OPEN_SUMMARY"]
    end

    private
      def lib_path
        if not Helper.is_test? and Gem::Specification::find_all_by_name('snapshot').any?
          return [Gem::Specification.find_by_name('snapshot').gem_dir, 'lib'].join('/')
        else
          return './lib'
        end
      end

      def available_devices
        # The order IS important, since those names are used to check for include?
        # and the iPhone 6 is inlucded in the iPhone 6 Plus
        {
          'iPhone6Plus' => "iPhone 6 Plus",
          'iPhone6' => "iPhone 6",
          'iPhone5' => "iPhone 5",
          'iPhone4' => "iPhone 4",
          'iPad' => "iPad",
          'Mac' => "Mac"
        }
      end
  end
end