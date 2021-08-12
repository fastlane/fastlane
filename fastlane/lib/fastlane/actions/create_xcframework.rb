module Fastlane
  module Actions
    module SharedValues
      XCFRAMEWORK_PATH ||= :XCFRAMEWORK_PATH
    end

    class CreateXcframeworkAction < Action
      PARAMETERS_TO_OPTIONS = { headers: '-headers', dsyms: '-debug-symbols' }

      def self.run(params)
        artifacts = normalized_artifact_info(params[:frameworks], [:dsyms]) || normalized_artifact_info(params[:libraries], [:headers, :dsyms])
        UI.user_error!("Please provide either :frameworks or :libraries to be packaged into the xcframework") unless artifacts

        artifacts_type = params[:frameworks] ? '-framework' : '-library'
        create_command = ['xcodebuild', '-create-xcframework']
        create_command << artifacts.map { |artifact, artifact_info| [artifacts_type, "\"#{artifact}\""] + artifact_info_as_options(artifact_info) }.flatten
        create_command << ['-output', "\"#{params[:output]}\""]
        create_command << ['-allow-internal-distribution'] if params[:allow_internal_distribution]

        if File.directory?(params[:output])
          UI.message("Deleting existing: #{params[:output]}")
          FileUtils.remove_dir(params[:output])
        end

        Actions.lane_context[SharedValues::XCFRAMEWORK_PATH] = params[:output]

        sh(create_command)
      end

      def self.normalized_artifact_info(artifact_info, valid_info)
        case artifact_info
        when Array
          artifact_info.map { |artifact| [artifact, {}] }.to_h
        when Hash
          artifact_info.transform_values { |artifact_info| artifact_info.transform_keys { |key| key.to_sym }.slice(*valid_info) }
        else
          artifact_info
        end
      end

      def self.artifact_info_as_options(artifact_info)
        artifact_info.map { |type, file| [PARAMETERS_TO_OPTIONS[type], "\"#{file}\""] }.flatten
      end

      def self.check_artifact_info(artifact_info)
        UI.user_error!("Headers and dSYMs information should be a hash") unless artifact_info.kind_of? Hash
        UI.user_error!("#{artifact_info[:headers]} doesn't exist or is not a directory") if artifact_info[:headers] && !File.directory?(artifact_info[:headers])
        UI.user_error!("#{artifact_info[:dsyms]} doesn't seem to be a dSYM archive") if artifact_info[:dsyms] && !File.directory?(artifact_info[:dsyms])
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
                                       is_string: false,
                                       optional: true,
                                       conflicting_options: [:libraries],
                                       verify_block: proc do |value|
                                         case value
                                         when Array, Hash
                                           normalized_artifact_info(value, [:dsyms]).each do |framework, framework_info|
                                             UI.user_error!("#{framework} doesn't end with '.framework'. Is this really a framework?") unless framework.end_with?('.framework')
                                             UI.user_error!("Couldn't find framework at #{framework}") unless File.exist?(framework)
                                             UI.user_error!("#{framework} doesn't seem to be a framework") unless File.directory?(framework)
                                             check_artifact_info(framework_info)
                                           end
                                         else
                                           UI.user_error!("frameworks should be an Array (['FrameworkA.framework', 'FrameworkB.framework']) or a Hash ({'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } })")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :libraries,
                                       env_name: "FL_CREATE_XCFRAMEWORK_LIBRARIES",
                                       description: "Libraries to add to the target xcframework, with their corresponding headers",
                                       is_string: false,
                                       optional: true,
                                       conflicting_options: [:frameworks],
                                       verify_block: proc do |value|
                                         case value
                                         when Array, Hash
                                           normalized_artifact_info(value, [:headers, :dsyms]).each do |library, library_info|
                                             UI.user_error!("Couldn't find library at #{library}") unless File.exist?(library)
                                             check_artifact_info(library_info)
                                           end
                                         else
                                           UI.user_error!("libraries should be an Array (['LibraryA.so', 'LibraryB.so']) or a Hash ({ 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'headers' } })")
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
