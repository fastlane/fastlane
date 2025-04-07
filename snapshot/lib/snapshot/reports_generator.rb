require_relative 'module'

module Snapshot
  class ReportsGenerator
    require 'erb'
    require 'fastimage'

    def html_path
      if Snapshot.config[:html_template]
        Snapshot.config[:html_template]
      else
        File.join(Snapshot::ROOT, "lib", "snapshot/page.html.erb")
      end
    end

    def generate
      UI.message("Generating HTML Report")

      screens_path = Snapshot.config[:output_directory]

      @data_by_language = {}
      @data_by_screen = {}

      Dir[File.join(screens_path, "*")].sort.each do |language_folder|
        language = File.basename(language_folder)
        Dir[File.join(language_folder, '*.png')].sort.each do |screenshot|
          file_name = File.basename(screenshot)
          available_devices.each do |key_name, output_name|
            next unless file_name.include?(key_name)
            # This screenshot is from this device

            @data_by_language[language] ||= {}
            @data_by_language[language][output_name] ||= []

            screen_name = file_name.sub(key_name + '-', '').sub('.png', '')
            @data_by_screen[screen_name] ||= {}
            @data_by_screen[screen_name][output_name] ||= {}

            resulting_path = File.join('.', language, file_name)
            @data_by_language[language][output_name] << resulting_path
            @data_by_screen[screen_name][output_name][language] = resulting_path
            break # to not include iPhone 6 and 6 Plus (name is contained in the other name)
          end
        end
      end

      html = ERB.new(File.read(html_path)).result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success("Successfully created HTML file with an overview of all the screenshots: '#{export_path}'")
      system("open '#{export_path}'") unless Snapshot.config[:skip_open_summary]
    end

    def xcode_8_and_below_device_name_mappings
      # The order IS important, since those names are used to check for include?
      # and the iPhone 6 is included in the iPhone 6 Plus
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
        'iPhoneSE' => "iPhone SE",
        'iPad2' => "iPad2",
        'iPadAir2' => 'iPad Air 2',
        'iPadPro(12.9-inch)' => 'iPad Air Pro (12.9-inch)',
        'iPadPro(9.7-inch)' => 'iPad Air Pro (9.7-inch)',
        'iPadPro(9.7inch)' => "iPad Pro (9.7-inch)",
        'iPadPro(12.9inch)' => "iPad Pro (12.9-inch)",
        'iPadPro' => "iPad Pro",
        'iPad' => "iPad",
        'Mac' => "Mac"
      }
    end

    def xcode_9_and_above_device_name_mappings
      {
        # snapshot in Xcode 9 saves screenshots with the SIMULATOR_DEVICE_NAME
        # which includes spaces
        'iPhone 15 Pro Max' => "iPhone 15 Pro Max",
        'iPhone 15 Pro' => "iPhone 15 Pro",
        'iPhone 15 Plus' => "iPhone 15 Plus",
        'iPhone 15' => "iPhone 15",
        'iPhone 14 Pro Max' => "iPhone 14 Pro Max",
        'iPhone 14 Pro' => "iPhone 14 Pro",
        'iPhone 14 Plus' => "iPhone 14 Plus",
        'iPhone 14' => "iPhone 14",
        'iPhone SE (3rd generation)' => "iPhone SE (3rd generation)",
        'iPhone 13 Pro Max' => "iPhone 13 Pro Max",
        'iPhone 13 Pro' => "iPhone 13 Pro",
        'iPhone 13 mini' => "iPhone 13 mini",
        'iPhone 13' => "iPhone 13",
        'iPhone 12 Pro Max' => "iPhone 12 Pro Max",
        'iPhone 12 Pro' => "iPhone 12 Pro",
        'iPhone 12 mini' => "iPhone 12 mini",
        'iPhone 12' => "iPhone 12",
        'iPhone SE (2nd generation)' => "iPhone SE (2nd generation)",
        'iPhone 11 Pro Max' => "iPhone 11 Pro Max",
        'iPhone 11 Pro' => "iPhone 11 Pro",
        'iPhone 11' => "iPhone 11",
        'iPhone XS Max' => "iPhone XS Max",
        'iPhone XS' => "iPhone XS",
        'iPhone XR' => "iPhone XR",
        'iPhone 8 Plus' => "iPhone 8 Plus",
        'iPhone 8' => "iPhone 8",
        'iPhone X' => "iPhone X",
        'iPhone 7 Plus' => "iPhone 7 Plus (5.5-Inch)",
        'iPhone 7' => "iPhone 7 (4.7-Inch)",
        'iPhone 6s Plus' => "iPhone 6s Plus (5.5-Inch)",
        'iPhone 6 Plus' => "iPhone 6 Plus (5.5-Inch)",
        'iPhone 6s' => "iPhone 6s (4.7-Inch)",
        'iPhone 6' => "iPhone 6 (4.7-Inch)",
        'iPhone 5s' => "iPhone 5s (4-Inch)",
        'iPhone 5' => "iPhone 5 (4-Inch)",
        'iPhone SE' => "iPhone SE",
        'iPhone 4s' => "iPhone 4s (3.5-Inch)",
        'iPad 2' => 'iPad 2',
        'iPad Air (5th generation)' => 'iPad Air (5th generation)',
        'iPad Air (4th generation)' => 'iPad Air (4th generation)',
        'iPad Air (3rd generation)' => 'iPad Air (3rd generation)',
        'iPad Air 2' => 'iPad Air 2',
        'iPad Air' => 'iPad Air',
        'iPad (10th generation)' => 'iPad (10th generation)',
        'iPad (9th generation)' => 'iPad (9th generation)',
        'iPad (8th generation)' => 'iPad (8th generation)',
        'iPad (7th generation)' => 'iPad (7th generation)',
        'iPad (6th generation)' => 'iPad (6th generation)',
        'iPad (5th generation)' => 'iPad (5th generation)',
        'iPad mini (6th generation)' => 'iPad mini (6th generation)',
        'iPad mini (5th generation)' => 'iPad mini (5th generation)',
        'iPad mini 4' => 'iPad mini 4',
        'iPad mini 3' => 'iPad mini 3',
        'iPad mini 2' => 'iPad mini 2',
        'iPad Pro (9.7-inch)' => 'iPad Pro (9.7-inch)',
        'iPad Pro (9.7 inch)' => 'iPad Pro (9.7-inch)', # iOS 10.3.1 simulator
        'iPad Pro (10.5-inch)' => 'iPad Pro (10.5-inch)',
        'iPad Pro (11-inch) (4th generation) (16GB)' => 'iPad Pro (11-inch) (4th generation) (16GB)',
        'iPad Pro (11-inch) (4th generation)' => 'iPad Pro (11-inch) (4th generation)',
        'iPad Pro (11-inch) (3rd generation)' => 'iPad Pro (11-inch) (3rd generation)',
        'iPad Pro (11-inch) (2nd generation)' => 'iPad Pro (11-inch) (2nd generation)',
        'iPad Pro (11-inch) (1st generation)' => 'iPad Pro (11-inch) (1st generation)',
        'iPad Pro (11-inch)' => 'iPad Pro (11-inch)',
        'iPad Pro (12.9-inch) (6th generation) (16GB)' => 'iPad Pro (12.9-inch) (6th generation) (16GB)',
        'iPad Pro (12.9-inch) (6th generation)' => 'iPad Pro (12.9-inch) (6th generation)',
        'iPad Pro (12.9-inch) (5th generation)' => 'iPad Pro (12.9-inch) (5th generation)',
        'iPad Pro (12.9-inch) (4th generation)' => 'iPad Pro (12.9-inch) (4th generation)',
        'iPad Pro (12.9-inch) (3rd generation)' => 'iPad Pro (12.9-inch) (3rd generation)',
        'iPad Pro (12.9-inch) (2nd generation)' => 'iPad Pro (12.9-inch) (2nd generation)',
        'iPad Pro (12.9-inch)' => 'iPad Pro (12.9-inch)',
        'iPad Pro (12.9 inch)' => 'iPad Pro (12.9-inch)', # iOS 10.3.1 simulator
        'iPad Pro' => 'iPad Pro (12.9-inch)', # iOS 9.3 simulator
        'iPod touch (7th generation)' => 'iPod touch (7th generation)',
        'Apple TV 4K (3rd generation)' => 'Apple TV 4K (3rd generation)',
        'Apple TV 4K (3rd generation) (at 1080p)' => 'Apple TV 4K (3rd generation) (at 1080p)',
        'Apple TV 4K (2nd generation)' => 'Apple TV 4K (2nd generation)',
        'Apple TV 4K (2nd generation) (at 1080p)' => 'Apple TV 4K (2nd generation) (at 1080p)',
        'Apple TV 4K (at 1080p)' => 'Apple TV 4K (at 1080p)',
        'Apple TV 4K' => 'Apple TV 4K',
        'Apple TV 1080p' => 'Apple TV',
        'Apple TV' => 'Apple TV',
        'Mac' => 'Mac',
        'Apple Watch Ultra 2 (49mm)' => 'Apple Watch Ultra 2 (49mm)',
        'Apple Watch SE (44mm)' => 'Apple Watch SE (44mm)',
        'Apple Watch SE (40mm)' => 'Apple Watch SE (40mm)',
        'Apple Watch Series 9 (45mm)' => 'Apple Watch Series 9 (45mm)',
        'Apple Watch Series 9 (41mm)' => 'Apple Watch Series 9 (41mm)',
        'Apple Watch Series 8 (45mm)' => 'Apple Watch Series 8 (45mm)',
        'Apple Watch Series 8 (41mm)' => 'Apple Watch Series 8 (41mm)',
        'Apple Watch Series 7 (45mm)' => 'Apple Watch Series 7 (45mm)',
        'Apple Watch Series 7 (41mm)' => 'Apple Watch Series 7 (41mm)',
        'Apple Watch Series 6 (44mm)' => 'Apple Watch Series 6 (44mm)',
        'Apple Watch Series 6 (40mm)' => 'Apple Watch Series 6 (40mm)',
        'Apple Watch Series 5 (44mm)' => 'Apple Watch Series 5 (44mm)',
        'Apple Watch Series 5 (40mm)' => 'Apple Watch Series 5 (40mm)',
        'Apple Watch Series 6 - 44mm' => 'Apple Watch Series 6 - 44mm',
        'Apple Watch Series 5 - 44mm' => 'Apple Watch Series 5 - 44mm'
      }
    end

    def available_devices
      if Helper.xcode_at_least?("9.0")
        return xcode_9_and_above_device_name_mappings
      else
        return xcode_8_and_below_device_name_mappings
      end
    end
  end
end
