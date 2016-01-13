module Fastlane
  module Actions
    # ResizeAction is based on work created and Copyright (c) 2014 Erik Sundin
    # Original source may be found under the MIT license at https://github.com/eriksundin/appicon
    class ResizeAppIconAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        Helper.log.info "Path to source icon: #{params[:iconPath]}"
        Helper.log.info "Path to Images.xcassets: #{params[:assetsPath]}"

        if params[:iconPath] and params[:assetsPath] and !params[:iconPath].empty? and !params[:assetsPath].empty?
          validate_image_magick!

          determine_icon! unless @icon = params[:iconPath]
          determine_asset_catalog! unless @asset_catalog = params[:assetsPath]

          validate_icon!
          validate_asset_catalog!

          icon_sets = Dir.glob(File.join(@asset_catalog, '*.appiconset'))
          abort("Could not find any Icon sets (.appiconset folders) in the asset catalog. Create one and then run this action again.") unless icon_sets.size > 0
          if icon_sets.size > 1
            @icon_set = determine_icon_set! icon_sets
          else
            @icon_set = icon_sets.first
          end

          @contents_file = File.join(@icon_set, 'Contents.json')
          contents = JSON.parse(File.read(@contents_file))
          contents['images'].each do |image|
            image_size = image['size']
            image_scale = image['scale']

            scaled_image_side = Integer(image_size.split('x').first.to_f * image_scale.sub('x', '').to_f)
            scaled_image_name = "Icon-#{image_size}-@#{image_scale}#{File.extname(@icon)}"
            scaled_image_output = File.join(@icon_set, scaled_image_name)

            # Generate each icon
            Helper.log.info "Building #{image_size} @ #{image_scale}. ✅"
            if system("convert #{@icon.shellescape} -resize #{scaled_image_side}x#{scaled_image_side} #{scaled_image_output.shellescape}")

              # Remove old icons that are not used any more
              previous_icon = image['filename']
              if previous_icon
                previous_icon_file = File.join(@icon_set, previous_icon)
                if File.exist?(previous_icon_file) and !scaled_image_name.eql?(previous_icon)
                  FileUtils.rm(previous_icon_file)
                end
              end

              image['filename'] = scaled_image_name

            else
              Helper.log.info 'Failed during the conversion process for some reason... 😱' and abort
            end
          end

          # Output the new JSON contents
          File.open(@contents_file, "w") do |f|
            f.write(JSON.pretty_generate(contents))
          end

          Helper.log.info 'All icons built and installed 👍'
        end
      end

      def self.validate_image_magick!
        abort('You need to install Image Magick! Check http://www.imagemagick.org for instructions.') unless system("which convert > /dev/null 2>&1")
      end

      def self.validate_icon!
        @icon = File.expand_path(@icon)
        abort("Oops! Can't find the source icon you specified. #{@icon}") unless File.exist?(@icon)
      end

      def self.validate_asset_catalog!
        @asset_catalog = File.expand_path(@asset_catalog)
        abort("Oops! Can't find the asset catalog you specified. #{@asset_catalog}") unless File.exist?(@asset_catalog)
        abort("Oops! It does not seem you specified a valid asset catalog.  It needs to be the .xcassets directory.") \
        unless File.directory?(@asset_catalog) and File.extname(@asset_catalog).eql?('.xcassets')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Resize a source 1024x1024 app icon image to all sizes in an .xcassets collection."
      end

      def self.details
        "Relies on ImageMagick to resize a source icon image into all required image sizes as defined in the specified .xcassets collection."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :iconPath,
                                       env_name: "FL_RESIZE_SOURCE_ICON_PATH",
                                       description: "The path to the original 1024x1024 image",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :assetsPath,
                                       env_name: "FL_RESIZE_ASSETS_PATH",
                                       description: "The path to the xcassets folder for the app icons",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: false)
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["@calebhicks"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
