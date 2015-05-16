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

        plist = Plist::parse_xml(File.join(archive, 'Info.plist'))
        app_name = Helper.test? ? 'MyApp.app' : File.basename(plist['ApplicationProperties']['ApplicationPath'])
        dsym_name = "#{app_name}.dSYM"
        dsym_folder_path = File.expand_path(File.join(archive, 'dSYMs'))
        zipped_dsym_path = File.expand_path(params[:dsym_path])

        Actions.lane_context[SharedValues::DSYM_ZIP_PATH] = zipped_dsym_path

        Actions.sh(%Q[cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "#{dsym_name}"])
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end

      def self.description
        'Creates a zipped dSYM in the project root from the .xcarchive'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                       description: 'Path to your xcarchive file. Optional if you use the `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE],
                                       optional: true,
                                       env_name: 'DSYM_ZIP_XCARCHIVE_PATH',
                                       verify_block: Proc.new do |value|
                                        raise "Couldn't find xcarchive file at path '#{value}'".red if !Helper.test? && !File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       description: 'Path for generated dsym. Optional, default is your apps root directory',
                                       optional: true,
                                       env_name: 'DSYM_ZIP_DSYM_PATH')
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
    end
  end
end
