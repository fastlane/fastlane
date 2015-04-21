require 'plist'

module Fastlane
  module Actions
    module SharedValues
      DSYM_ZIP_PATH = :DSYM_ZIP_PATH
    end

    class DsymZipAction < Action
      def self.run(params)
        archive = params[:archive_path]

        plist = Plist::parse_xml(File.join(archive, 'Info.plist'))
        app_name = File.basename(plist['ApplicationProperties']['ApplicationPath'])
        dsym_name = "#{app_name}.dSYM"
        dsym_folder_path = File.expand_path(File.join(archive, 'dSYMs'))
        zipped_dsym_path = File.expand_path(File.join("#{File.basename(archive, '.*')}.app.dSYM.zip"))

        Actions.sh(%Q[cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "#{dsym_name}"])

        Actions.lane_context[SharedValues::DSYM_ZIP_PATH] = zipped_dsym_path

        Helper.log.info 'Succesfully created .dSYM.zip file.'.green
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.description
        'Creates a zipped dSYM in the project root from the .xcarchive.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                       description: 'Path to your xcarchive file. Optional if you use the `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE],
                                       optional: true,
                                       env_name: 'DSYM_ZIP_XCARCHIVE_PATH',
                                       verify_block: Proc.new do |value|
                                        raise "Couldn't find xcarchive file at path '#{value}'".red unless File.exists?(value)
                                       end)
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
