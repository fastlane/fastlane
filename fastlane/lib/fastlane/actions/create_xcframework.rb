module Fastlane
  module Actions
    module SharedValues
      XCFRAMEWORK_PATH ||= :XCFRAMEWORK_PATH
    end

    class CreateXcframeworkAction < Action
      PARAMETERS_TO_OPTIONS = { headers: '-headers', dsyms: '-debug-symbols' }

      def self.run(params)
        artifacts = normalized_artifact_info(params[:frameworks], [:dsyms]) ||
                    normalized_artifact_info(params[:frameworks_with_dsyms], [:dsyms]) ||
                    normalized_artifact_info(params[:libraries], [:headers, :dsyms]) ||
                    normalized_artifact_info(params[:libraries_with_headers_or_dsyms], [:headers, :dsyms])

        UI.user_error!("Please provide either :frameworks, :frameworks_with_dsyms, :libraries or :libraries_with_headers_or_dsyms to be packaged into the xcframework") unless artifacts

        artifacts_type = params[:frameworks] || params[:frameworks_with_dsyms] ? '-framework' : '-library'
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

      def self.normalized_artifact_info(artifacts_with_info, valid_info)
        case artifacts_with_info
        when Array
          artifacts_with_info.map { |artifact| [artifact, {}] }.to_h
        when Hash
          # Convert keys of artifact info to symbols ('dsyms' to :dsyms) and only keep keys we are interested in
          # For example with valid_info = [:dsyms]
          #  { 'FrameworkA.framework' => { 'dsyms' => 'FrameworkA.framework.dSYM', 'foo' => bar } }
          # gets converted to
          #  { 'FrameworkA.framework' => { dsyms: 'FrameworkA.framework.dSYM' } }
          artifacts_with_info.transform_values { |artifact_info| artifact_info.transform_keys(&:to_sym).slice(*valid_info) }
        else
          artifacts_with_info
        end
      end

      def self.artifact_info_as_options(artifact_info)
        artifact_info.map { |type, file| [PARAMETERS_TO_OPTIONS[type], "\"#{file}\""] }.flatten
      end

      def self.check_artifact_info(artifact_info)
        UI.user_error!("Headers and dSYMs information should be a hash") unless artifact_info.kind_of?(Hash)
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

          If you want to package several frameworks just provide one of:

            * An array containing the list of frameworks using the :frameworks parameter
              (if they have no associated dSYMs):
                ['FrameworkA.framework', 'FrameworkB.framework']

            * A hash containing the list of frameworks with their dSYMs using the
              :frameworks_with_dsyms parameter:
                {
                  'FrameworkA.framework' => {},
                  'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' }
                }

          If you want to package several libraries just provide one of:

            * An array containing the list of libraries using the :libraries parameter
              (if they have no associated headers or dSYMs):
                ['LibraryA.so', 'LibraryB.so']

            * A hash containing the list of libraries with their headers and dSYMs
              using the :libraries_with_headers_or_dsyms parameter:
                {
                  'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' },
                  'LibraryB.so' => { headers: 'headers' }
                }

          Finally specify the location of the xcframework to be generated using the :output
          parameter.
        DETAILS
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :frameworks,
                                       env_name: "FL_CREATE_XCFRAMEWORK_FRAMEWORKS",
                                       description: "Frameworks (without dSYMs) to add to the target xcframework",
                                       type: Array,
                                       optional: true,
                                       conflicting_options: [:frameworks_with_dsyms, :libraries, :libraries_with_headers_or_dsyms],
                                       verify_block: proc do |value|
                                         normalized_artifact_info(value, [:dsyms]).each do |framework, framework_info|
                                           UI.user_error!("#{framework} doesn't end with '.framework'. Is this really a framework?") unless framework.end_with?('.framework')
                                           UI.user_error!("Couldn't find framework at #{framework}") unless File.exist?(framework)
                                           UI.user_error!("#{framework} doesn't seem to be a framework") unless File.directory?(framework)
                                           check_artifact_info(framework_info)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :frameworks_with_dsyms,
                                       env_name: "FL_CREATE_XCFRAMEWORK_FRAMEWORKS_WITH_DSYMS",
                                       description: "Frameworks (with dSYMs) to add to the target xcframework",
                                       type: Hash,
                                       optional: true,
                                       conflicting_options: [:frameworks, :libraries, :libraries_with_headers_or_dsyms],
                                       verify_block: proc do |value|
                                         normalized_artifact_info(value, [:dsyms]).each do |framework, framework_info|
                                           UI.user_error!("#{framework} doesn't end with '.framework'. Is this really a framework?") unless framework.end_with?('.framework')
                                           UI.user_error!("Couldn't find framework at #{framework}") unless File.exist?(framework)
                                           UI.user_error!("#{framework} doesn't seem to be a framework") unless File.directory?(framework)
                                           check_artifact_info(framework_info)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :libraries,
                                       env_name: "FL_CREATE_XCFRAMEWORK_LIBRARIES",
                                       description: "Libraries (without headers or dSYMs) to add to the target xcframework",
                                       type: Array,
                                       optional: true,
                                       conflicting_options: [:frameworks, :frameworks_with_dsyms, :libraries_with_headers_or_dsyms],
                                       verify_block: proc do |value|
                                         normalized_artifact_info(value, [:headers, :dsyms]).each do |library, library_info|
                                           UI.user_error!("Couldn't find library at #{library}") unless File.exist?(library)
                                           check_artifact_info(library_info)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :libraries_with_headers_or_dsyms,
                                       env_name: "FL_CREATE_XCFRAMEWORK_LIBRARIES_WITH_HEADERS_OR_DSYMS",
                                       description: "Libraries (with headers or dSYMs) to add to the target xcframework",
                                       type: Hash,
                                       optional: true,
                                       conflicting_options: [:frameworks, :frameworks_with_dsyms, :libraries],
                                       verify_block: proc do |value|
                                         normalized_artifact_info(value, [:headers, :dsyms]).each do |library, library_info|
                                           UI.user_error!("Couldn't find library at #{library}") unless File.exist?(library)
                                           check_artifact_info(library_info)
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
          "create_xcframework(frameworks_with_dsyms: {'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } }, output: 'UniversalFramework.xcframework')",
          "create_xcframework(libraries: ['LibraryA.so', 'LibraryB.so'], output: 'UniversalFramework.xcframework')",
          "create_xcframework(libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'LibraryBHeaders' } }, output: 'UniversalFramework.xcframework')"
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
