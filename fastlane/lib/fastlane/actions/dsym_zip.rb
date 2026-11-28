require 'plist'

module Fastlane
  module Actions
    module SharedValues
      DSYM_ZIP_PATH = :DSYM_ZIP_PATH
    end

    class DsymZipAction < Action
      def self.run(params)
        archive = params[:archive_path]
        params[:dsym_path] ||= File.join("#{File.basename(archive, '.*')}.app.dSYM.zip")

        dsym_folder_path = File.expand_path(File.join(archive, 'dSYMs'))
        zipped_dsym_path = File.expand_path(params[:dsym_path])

        Actions.lane_context[SharedValues::DSYM_ZIP_PATH] = zipped_dsym_path

        if params[:all]
          Actions.sh(%(cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "#{dsym_folder_path}"/*.dSYM))
        else
          plist = Plist.parse_xml(File.join(archive, 'Info.plist'))
          app_name = Helper.test? ? 'MyApp.app' : File.basename(plist['ApplicationProperties']['ApplicationPath'])
          dsym_name = "#{app_name}.dSYM"
          Actions.sh(%(cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "#{dsym_name}"))
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.description
        'Creates a zipped dSYM in the project root from the .xcarchive'
      end

      def self.details
        "You can manually specify the path to the xcarchive (not needed if you use `xcodebuild`/`xcarchive` to build your archive)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                       description: 'Path to your xcarchive file. Optional if you use the `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE],
                                       default_value_dynamic: true,
                                       optional: true,
                                       env_name: 'DSYM_ZIP_XCARCHIVE_PATH',
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find xcarchive file at path '#{value}'") if !Helper.test? && !File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       description: 'Path for generated dsym. Optional, default is your apps root directory',
                                       optional: true,
                                       env_name: 'DSYM_ZIP_DSYM_PATH'),
          FastlaneCore::ConfigItem.new(key: :all,
                                       description: 'Whether or not all dSYM files are to be included. Optional, default is false in which only your app dSYM is included',
                                       default_value: false,
                                       optional: true,
                                       type: Boolean,
                                       env_name: 'DSYM_ZIP_ALL')
        ]
      end

      def self.output
        [
          ['DSYM_ZIP_PATH', 'The named of the zipped dSYM']
        ]
      end

      def self.author
        'lmirosevic'
      end

      def self.example_code
        [
          'dsym_zip',
          'dsym_zip(
            archive_path: "MyApp.xcarchive"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
