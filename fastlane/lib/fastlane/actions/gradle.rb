require 'pathname'
require 'shellwords'

module Fastlane
  module Actions
    module SharedValues
      GRADLE_APK_OUTPUT_PATH = :GRADLE_APK_OUTPUT_PATH
      GRADLE_ALL_APK_OUTPUT_PATHS = :GRADLE_ALL_APK_OUTPUT_PATHS
      GRADLE_AAB_OUTPUT_PATH = :GRADLE_AAB_OUTPUT_PATH
      GRADLE_ALL_AAB_OUTPUT_PATHS = :GRADLE_ALL_AAB_OUTPUT_PATHS
      GRADLE_OUTPUT_JSON_OUTPUT_PATH = :GRADLE_OUTPUT_JSON_OUTPUT_PATH
      GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS = :GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS
      GRADLE_MAPPING_TXT_OUTPUT_PATH = :GRADLE_MAPPING_TXT_OUTPUT_PATH
      GRADLE_ALL_MAPPING_TXT_OUTPUT_PATHS = :GRADLE_ALL_MAPPING_TXT_OUTPUT_PATHS
      GRADLE_FLAVOR = :GRADLE_FLAVOR
      GRADLE_BUILD_TYPE = :GRADLE_BUILD_TYPE
    end

    class GradleAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        task = params[:task]
        flavor = params[:flavor]
        build_type = params[:build_type]
        tasks = params[:tasks]

        gradle_task = gradle_task(task, flavor, build_type, tasks)

        UI.user_error!('Please pass a gradle task or tasks') if gradle_task.empty?

        project_dir = params[:project_dir]

        gradle_path_param = params[:gradle_path] || './gradlew'

        # Get the path to gradle, if it's an absolute path we take it as is, if it's relative we assume it's relative to the project_dir
        gradle_path = if Pathname.new(gradle_path_param).absolute?
                        File.expand_path(gradle_path_param)
                      else
                        File.expand_path(File.join(project_dir, gradle_path_param))
                      end

        # Ensure we ended up with a valid path to gradle
        UI.user_error!("Couldn't find gradlew at path '#{File.expand_path(gradle_path)}'") unless File.exist?(gradle_path)

        # Construct our flags
        flags = []
        flags << "-p #{project_dir.shellescape}"
        flags << params[:properties].map { |k, v| "-P#{k.to_s.shellescape}=#{v.to_s.shellescape}" }.join(' ') unless params[:properties].nil?
        flags << params[:system_properties].map { |k, v| "-D#{k.to_s.shellescape}=#{v.to_s.shellescape}" }.join(' ') unless params[:system_properties].nil?
        flags << params[:flags] unless params[:flags].nil?

        # Run the actual gradle task
        gradle = Helper::GradleHelper.new(gradle_path: gradle_path)

        # If these were set as properties, then we expose them back out as they might be useful to others
        Actions.lane_context[SharedValues::GRADLE_BUILD_TYPE] = build_type if build_type
        Actions.lane_context[SharedValues::GRADLE_FLAVOR] = flavor if flavor

        # We run the actual gradle task
        result = gradle.trigger(task: gradle_task,
                                serial: params[:serial],
                                flags: flags.join(' '),
                                print_command: params[:print_command],
                                print_command_output: params[:print_command_output])

        # If we didn't build, then we return now, as it makes no sense to search for apk's in a non-`assemble` or non-`build` scenario
        return result unless gradle_task =~ /\b(assemble)/ || gradle_task =~ /\b(bundle)/

        apk_search_path = File.join(project_dir, '**', 'build', 'outputs', 'apk', '**', '*.apk')
        aab_search_path = File.join(project_dir, '**', 'build', 'outputs', 'bundle', '**', '*.aab')
        output_json_search_path = File.join(project_dir, '**', 'build', 'outputs', 'apk', '**', 'output*.json') # output.json in Android Studio 3 and output-metadata.json in Android Studio 4
        mapping_txt_search_path = File.join(project_dir, '**', 'build', 'outputs', 'mapping', '**', 'mapping.txt')

        # Our apk/aab is now built, but there might actually be multiple ones that were built if a flavor was not specified in a multi-flavor project (e.g. `assembleRelease`)
        # However, we're not interested in unaligned apk's...
        new_apks = Dir[apk_search_path].reject { |path| path =~ /^.*-unaligned.apk$/i }
        new_apks = new_apks.map { |path| File.expand_path(path) }
        new_aabs = Dir[aab_search_path]
        new_aabs = new_aabs.map { |path| File.expand_path(path) }
        new_output_jsons = Dir[output_json_search_path]
        new_output_jsons = new_output_jsons.map { |path| File.expand_path(path) }
        new_mapping_txts = Dir[mapping_txt_search_path]
        new_mapping_txts = new_mapping_txts.map { |path| File.expand_path(path) }

        # We expose all of these new apks and aabs
        Actions.lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS] = new_apks
        Actions.lane_context[SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS] = new_aabs
        Actions.lane_context[SharedValues::GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS] = new_output_jsons
        Actions.lane_context[SharedValues::GRADLE_ALL_MAPPING_TXT_OUTPUT_PATHS] = new_mapping_txts

        # We also take the most recent apk and aab to return as SharedValues::GRADLE_APK_OUTPUT_PATH and SharedValues::GRADLE_AAB_OUTPUT_PATH
        # This is the one that will be relevant for most projects that just build a single build variant (flavor + build type combo).
        # In multi build variants this value is undefined
        last_apk_path = new_apks.sort_by(&File.method(:mtime)).last
        last_aab_path = new_aabs.sort_by(&File.method(:mtime)).last
        last_output_json_path = new_output_jsons.sort_by(&File.method(:mtime)).last
        last_mapping_txt_path = new_mapping_txts.sort_by(&File.method(:mtime)).last
        Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = File.expand_path(last_apk_path) if last_apk_path
        Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH] = File.expand_path(last_aab_path) if last_aab_path
        Actions.lane_context[SharedValues::GRADLE_OUTPUT_JSON_OUTPUT_PATH] = File.expand_path(last_output_json_path) if last_output_json_path
        Actions.lane_context[SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH] = File.expand_path(last_mapping_txt_path) if last_mapping_txt_path

        # Give a helpful message in case there were no new apks or aabs. Remember we're only running this code when assembling, in which case we certainly expect there to be an apk or aab
        UI.message('Couldn\'t find any new signed apk files...') if new_apks.empty? && new_aabs.empty?

        return result
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def self.gradle_task(task, flavor, build_type, tasks)
        gradle_task = [task, flavor, build_type].join

        if gradle_task.empty? && !tasks.nil?
          gradle_task = tasks.join(' ')
        end

        gradle_task
      end

      def self.step_text(params)
        task = params[:task]
        flavor = params[:flavor]
        build_type = params[:build_type]
        tasks = params[:tasks]

        gradle_task = gradle_task(task, flavor, build_type, tasks)

        return gradle_task
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'All gradle related actions, including building and testing your Android app'
      end

      def self.details
        'Run `./gradlew tasks` to get a list of all available gradle tasks for your project'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :task,
                                       env_name: 'FL_GRADLE_TASK',
                                       description: 'The gradle task you want to execute, e.g. `assemble`, `bundle` or `test`. For tasks such as `assembleMyFlavorRelease` you should use gradle(task: \'assemble\', flavor: \'Myflavor\', build_type: \'Release\')',
                                       conflicting_options: [:tasks],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :flavor,
                                       env_name: 'FL_GRADLE_FLAVOR',
                                       description: 'The flavor that you want the task for, e.g. `MyFlavor`. If you are running the `assemble` task in a multi-flavor project, and you rely on Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] then you must specify a flavor here or else this value will be undefined',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_type,
                                       env_name: 'FL_GRADLE_BUILD_TYPE',
                                       description: 'The build type that you want the task for, e.g. `Release`. Useful for some tasks such as `assemble`',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :tasks,
                                       type: Array,
                                       env_name: 'FL_GRADLE_TASKS',
                                       description: 'The multiple gradle tasks that you want to execute, e.g. `[assembleDebug, bundleDebug]`',
                                       conflicting_options: [:task],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :flags,
                                       env_name: 'FL_GRADLE_FLAGS',
                                       description: 'All parameter flags you want to pass to the gradle command, e.g. `--exitcode --xml file.xml`',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_dir,
                                       env_name: 'FL_GRADLE_PROJECT_DIR',
                                       description: 'The root directory of the gradle project',
                                       default_value: '.'),
          FastlaneCore::ConfigItem.new(key: :gradle_path,
                                       env_name: 'FL_GRADLE_PATH',
                                       description: 'The path to your `gradlew`. If you specify a relative path, it is assumed to be relative to the `project_dir`',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: 'FL_GRADLE_PROPERTIES',
                                       description: 'Gradle properties to be exposed to the gradle script',
                                       optional: true,
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :system_properties,
                                       env_name: 'FL_GRADLE_SYSTEM_PROPERTIES',
                                       description: 'Gradle system properties to be exposed to the gradle script',
                                       optional: true,
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :serial,
                                       env_name: 'FL_ANDROID_SERIAL',
                                       description: 'Android serial, which device should be used for this command',
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :print_command,
                                       env_name: 'FL_GRADLE_PRINT_COMMAND',
                                       description: 'Control whether the generated Gradle command is printed as output before running it (true/false)',
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :print_command_output,
                                       env_name: 'FL_GRADLE_PRINT_COMMAND_OUTPUT',
                                       description: 'Control whether the output produced by given Gradle command is printed while running (true/false)',
                                       type: Boolean,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['GRADLE_APK_OUTPUT_PATH', 'The path to the newly generated apk file. Undefined in a multi-variant assemble scenario'],
          ['GRADLE_ALL_APK_OUTPUT_PATHS', 'When running a multi-variant `assemble`, the array of signed apk\'s that were generated'],
          ['GRADLE_FLAVOR', 'The flavor, e.g. `MyFlavor`'],
          ['GRADLE_BUILD_TYPE', 'The build type, e.g. `Release`'],
          ['GRADLE_AAB_OUTPUT_PATH', 'The path to the most recent Android app bundle'],
          ['GRADLE_ALL_AAB_OUTPUT_PATHS', 'The paths to the most recent Android app bundles'],
          ['GRADLE_OUTPUT_JSON_OUTPUT_PATH', 'The path to the most recent output.json file'],
          ['GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS', 'The path to the newly generated output.json files'],
          ['GRADLE_MAPPING_TXT_OUTPUT_PATH', 'The path to the most recent mapping.txt file'],
          ['GRADLE_ALL_MAPPING_TXT_OUTPUT_PATHS', 'The path to the newly generated mapping.txt files']
        ]
      end

      def self.return_value
        'The output of running the gradle task'
      end

      def self.authors
        ['KrauseFx', 'lmirosevic']
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform) # we support iOS as cross platforms apps might want to call `gradle` also
      end

      def self.example_code
        [
          'gradle(
            task: "assemble",
            flavor: "WorldDomination",
            build_type: "Release"
          )
          ```

          To build an AAB use:
          ```ruby
          gradle(
            task: "bundle",
            flavor: "WorldDomination",
            build_type: "Release"
          )
          ```

          You can pass multiple gradle tasks:
          ```ruby
          gradle(
            tasks: ["assembleDebug", "bundleDebug"]
          )
          ```

          You can pass properties to gradle:
          ```ruby
          gradle(
            # ...

            properties: {
              "exampleNumber" => 100,
              "exampleString" => "1.0.0",
              # ...
            }
          )
          ```

          You can use this to change the version code and name of your app:
          ```ruby
          gradle(
            # ...

            properties: {
              "android.injected.version.code" => 100,
              "android.injected.version.name" => "1.0.0",
              # ...
            }
          )
          ```

          You can use this to automatically [sign and zipalign](https://developer.android.com/studio/publish/app-signing.html) your app:
          ```ruby
          gradle(
            task: "assemble",
            build_type: "Release",
            print_command: false,
            properties: {
              "android.injected.signing.store.file" => "keystore.jks",
              "android.injected.signing.store.password" => "store_password",
              "android.injected.signing.key.alias" => "key_alias",
              "android.injected.signing.key.password" => "key_password",
            }
          )
          ```

          If you need to pass sensitive information through the `gradle` action, and don\'t want the generated command to be printed before it is run, you can suppress that:
          ```ruby
          gradle(
            # ...
            print_command: false
          )
          ```

          You can also suppress printing the output generated by running the generated Gradle command:
          ```ruby
          gradle(
            # ...
            print_command_output: false
          )
          ```

          To pass any other CLI flags to gradle use:
          ```ruby
          gradle(
            # ...

            flags: "--exitcode --xml file.xml"
          )
          ```

          Delete the build directory, generated APKs and AABs
          ```ruby
          gradle(
            task: "clean"
          )'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
