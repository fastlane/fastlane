module Fastlane
  module Actions
    module SharedValues
      XCFRAMEWORK_PATH ||= :XCFRAMEWORK_PATH
    end

    class CreateXcframeworkAction < Action
      def self.run(params)
        UI.user_error!("Please provide either :frameworks or :libraries to be packaged into the xcframework") unless params[:frameworks] || params[:libraries]

        create_command = ['xcodebuild', '-create-xcframework']
        create_command << params[:frameworks].map { |framework| ['-framework', "\"#{framework}\""] }.flatten if params[:frameworks]
        create_command << params[:libraries].map { |library, headers| ['-library', "\"#{library}\""] + (headers.empty? ? [] : ['-headers', "\"#{headers}\""]) } if params[:libraries]
        create_command << ['-output', "\"#{params[:output]}\""]
        create_command << ['-allow-internal-distribution'] if params[:allow_internal_distribution]

        Actions.lane_context[SharedValues::XCFRAMEWORK_PATH] = params[:output]

        sh(create_command)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Package multiple build configs of a library/framework into a single xcframework"
      end

      def self.details
        <<~DETAILS
          Utility for packaging multiple build configurations of a given library
          or framework into a single xcframework.

          If you want to package several frameworks just provide an array containing
          the list of frameworks to be packaged using the :frameworks parameter.

          If you want to package several libraries with their corresponding headers
          provide a hash containing the library as the key and the directory containing
          its headers as the value (or an empty string if there are no headers associated
          with the provided library).

          Finally specify the location of the xcframework to be generated using the :output
          parameter.
        DETAILS
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :frameworks,
                                       env_name: "FL_CREATE_XCFRAMEWORK_FRAMEWORKS",
                                       description: "Frameworks to add to the target xcframework",
                                       type: Array,
                                       optional: true,
                                       conflicting_options: [:libraries],
                                       verify_block: proc do |value|
                                         value.each do |framework|
                                           UI.user_error!("#{framework} doesn't end with '.framework'. Is this really a framework?") unless framework.end_with?('.framework')
                                           UI.user_error!("Couldn't find framework at #{framework}") unless File.exist?(framework)
                                           UI.user_error!("#{framework} doesn't seem to be a framework") unless File.directory?(framework)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :libraries,
                                       env_name: "FL_CREATE_XCFRAMEWORK_LIBRARIES",
                                       description: "Libraries to add to the target xcframework, with their corresponding headers",
                                       type: Hash,
                                       optional: true,
                                       conflicting_options: [:frameworks],
                                       verify_block: proc do |value|
                                         value.each do |library, headers|
                                           UI.user_error!("Couldn't find library at #{library}") unless File.exist?(library)
                                           UI.user_error!("#{headers} doesn't exist or is not a directory") unless headers.empty? || File.directory?(headers)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :output,
                                       env_name: "FL_CREATE_XCFRAMEWORK_OUTPUT",
                                       description: "The path to write the xcframework to",
                                       type: String,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :allow_internal_distribution,
                                       env_name: "FL_CREATE_XCFRAMEWORK_ALLOW_INTERNAL_DISTRIBUTION",
                                       description: "Specifies that the created xcframework contains information not suitable for public distribution",
                                       type: Boolean,
                                       optional: true,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['XCFRAMEWORK_PATH', 'Location of the generated xcframework']
        ]
      end

      def self.return_value
      end

      def self.example_code
        [
          "create_xcframework(frameworks: ['FrameworkA.framework', 'FrameworkB.framework'], output: 'UniversalFramework.xcframework')",
          "create_xcframework(libraries: { 'LibraryA.so' => '', 'LibraryB.so' => 'LibraryBHeaders'}, output: 'UniversalFramework.xcframework')"
        ]
      end

      def self.category
        :building
      end

      def self.authors
        ["jgongo"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
