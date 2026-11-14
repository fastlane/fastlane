module Fastlane
  module Helper
    class XcodeprojHelper
      DEPENDENCY_MANAGER_DIRS = ['Pods', 'Carthage'].freeze

      def self.find(dir)
        xcodeproj_paths = Dir[File.expand_path(File.join(dir, '**/*.xcodeproj'))]
        xcodeproj_paths.reject { |path| %r{/(#{DEPENDENCY_MANAGER_DIRS.join('|')})/.*.xcodeproj} =~ path }
      end

      def self.get_project!(xcodeproj_path_or_dir)
        require 'xcodeproj'

        if File.extname(xcodeproj_path_or_dir) == ".xcodeproj"
          project_path = xcodeproj_path_or_dir
        else
          project_path = Dir.glob("#{xcodeproj_path_or_dir}/*.xcodeproj").first
        end

        if project_path && File.exist?(project_path)
          return open_project!(project_path)
        else
          UI.user_error!("Unable to find Xcode project at #{project_path || xcodeproj_path_or_dir}")
        end
      end

      # Opens the project at the given path.
      # A project in Xcode's JSON format needs a version of the xcodeproj gem that can read that format. An older
      # version only reports that `project.pbxproj` doesn't exist, so this method tells the user to update the gem.
      def self.open_project!(xcodeproj_path)
        require 'xcodeproj'

        if json_format?(xcodeproj_path) && !Xcodeproj::Project.const_defined?(:JSONFormat, false)
          UI.user_error!("'#{xcodeproj_path}' uses Xcode's JSON project format (project.xcproj), which the installed version of the xcodeproj gem can't open. Update the xcodeproj gem to a version that supports the JSON project format.")
        end
        Xcodeproj::Project.open(xcodeproj_path)
      end

      # Returns whether the project uses Xcode's JSON project format, which stores the project in
      # `project.xcproj` instead of `project.pbxproj`.
      def self.json_format?(xcodeproj_path)
        File.exist?(File.join(xcodeproj_path, "project.xcproj"))
      end

      # Returns the path of the file that stores the project.
      def self.project_file_path(xcodeproj_path)
        File.join(xcodeproj_path, json_format?(xcodeproj_path) ? "project.xcproj" : "project.pbxproj")
      end

      # Returns whether the project file has a format that is too old for the code signing actions.
      # Xcode has stored TargetAttributes in projects for a long time, so a project without them is very old.
      # Projects in Xcode's JSON format are the exception, because they only keep TargetAttributes for legacy signing settings.
      def self.very_old_project_format?(project)
        !project.root_object.attributes["TargetAttributes"] && !json_format?(project.path)
      end

      # Returns the given project path, or the path of the only project in the current directory.
      # Returns nil when no path is given and the current directory has no project or more than one.
      def self.single_project_path(xcodeproj_path)
        return xcodeproj_path if xcodeproj_path

        paths = Dir.glob("*.xcodeproj")
        paths.first if paths.count == 1
      end

      def self.get_single_project!(xcodeproj_path)
        project_path = single_project_path(xcodeproj_path)
        UI.user_error!("Could not find a single Xcode project in the current directory. Pass the project with the `xcodeproj` option.") unless project_path
        get_project!(project_path)
      end

      # Returns the different values of a build setting in the project's and its targets' build configurations.
      # Values that only an xcconfig file sets are not included.
      def self.build_setting_values(project, build_setting)
        ([project] + project.targets)
          .flat_map(&:build_configurations)
          .map { |config| config.build_settings[build_setting] }
          .compact
          .uniq
      end

      # Returns the build number, which is the CURRENT_PROJECT_VERSION build setting.
      # Build configurations can set different values. A target that Xcode just created starts at 1, for example.
      # This method then returns the highest value, so that the next build number is higher than every existing one.
      def self.current_build_number!(project)
        build_numbers = build_setting_values(project, "CURRENT_PROJECT_VERSION")
        if build_numbers.empty?
          UI.user_error!("Apple Generic Versioning is not enabled in this project.\nBefore being able to increment and read the version number from your Xcode project, you first need to setup your project properly. Please follow the guide at https://developer.apple.com/library/content/qa/qa1827/_index.html")
        end
        build_numbers.max_by { |build_number| build_number.split(".").map(&:to_i) }
      end

      # Returns the paths of the existing Info.plist files that the project's build configurations use, sorted.
      # Paths are relative to the project's directory. They can start with a reference to that directory, which is
      # SRCROOT or PROJECT_DIR in either `$(...)` or `${...}` form.
      def self.info_plist_paths(project)
        build_setting_values(project, "INFOPLIST_FILE")
          .map { |path| File.expand_path(path.sub(%r{\A\$[({](SRCROOT|PROJECT_DIR)[)}]/}, ""), project.project_dir) }
          .uniq
          .sort
          .select { |path| File.exist?(path) }
      end

      # Returns the values of a key in the project's Info.plist files, in the order of info_plist_paths.
      def self.info_plist_values(project, key)
        require 'xcodeproj'
        info_plist_paths(project).map { |path| Xcodeproj::Plist.read_from_path(path)[key] }.compact
      end

      # Sets a key in each of the project's Info.plist files that already has the key with a literal value.
      # Values that refer to a build setting, such as `$(CURRENT_PROJECT_VERSION)`, already follow that build setting and stay as they are.
      # Returns the paths of the files that changed.
      def self.update_info_plist_value(project, key, value)
        require 'xcodeproj'
        info_plist_paths(project).select do |path|
          current_value = Xcodeproj::Plist.read_from_path(path)[key]
          next false if current_value.nil? || current_value == value || current_value.to_s =~ /\$[({]/

          replace_info_plist_string(path, key, value)
          true
        end
      end

      # Replaces the string value of a key in the text of an XML Info.plist file, and leaves the rest of the file as it is.
      # Writing the file again from its parsed contents would reorder and reformat it. The xcodeproj gem's plist writer
      # would also turn date and data values into text that Xcode cannot read.
      def self.replace_info_plist_string(path, key, value)
        require 'cgi'
        content = File.read(path)
        string_value = %r{(<key>#{Regexp.escape(key)}</key>\s*<string>)[^<]*(</string>)}
        UI.user_error!("Could not update #{key} in #{path}, because the file does not store it as an XML string. Set #{key} to #{value} in that file yourself.") unless content =~ string_value

        File.write(path, content.sub(string_value) { "#{$1}#{CGI.escapeHTML(value)}#{$2}" })
      end

      def self.update_project_build_setting(project, build_setting, value)
        changed = { project: false, xcconfig: false }

        ([project] + project.targets).each do |item|
          item.build_configurations.each do |config|
            result = update_build_configuration_build_setting(config, build_setting, value)
            changed[:project] ||= result[:project]
            changed[:xcconfig] ||= result[:xcconfig]
          end
        end

        changed
      end

      # Writes a build setting that update_project_build_setting changed in the project to the project file.
      # In a `project.pbxproj` file, this method replaces the value in each line that sets the build setting, as
      # agvtool did. The rest of the file stays as it is. A save through the xcodeproj gem writes the whole file again.
      # That save removes the attributes that the gem does not know, and it changes the parts of the file that the
      # gem formats differently from Xcode.
      # The xcodeproj gem saves the project when the file has no such line. That includes every project in Xcode's
      # JSON format, which has no `project.pbxproj` file.
      def self.save_project_build_setting(project, build_setting, value)
        path = File.join(project.path, "project.pbxproj")
        setting_lines = /^(\s*"?#{Regexp.escape(build_setting)}(?:\[[^\]]+\])*"? = ).*;$/
        content = File.exist?(path) && File.read(path, encoding: "UTF-8").gsub!(setting_lines) { "#{$1}#{pbxproj_string(value)};" }
        content ? File.write(path, content) : project.save
      end

      # Returns a string as a `project.pbxproj` file stores it. The string is in quotes unless it only has letters,
      # digits, and the characters `_`, `.`, `$` and `/`. The writer of the xcodeproj gem follows the same rule.
      def self.pbxproj_string(string)
        require 'xcodeproj'
        string =~ %r{\A\z|[^\w.$/]|\A___} ? %("#{Nanaimo::Unicode.quotify_string(string)}") : string
      end

      def self.update_build_configuration_build_setting(config, build_setting, value)
        changed = { project: false, xcconfig: false }
        matching_keys = matching_build_setting_keys(config.build_settings, build_setting)

        unless matching_keys.empty?
          matching_keys.each do |key|
            next if config.build_settings[key] == value

            config.build_settings[key] = value
            changed[:project] = true
          end
        end

        changed[:xcconfig] = update_xcconfig_build_setting(config, build_setting, value)
        changed
      end

      def self.update_xcconfig_build_setting(config, build_setting, value)
        return false unless config.respond_to?(:base_configuration_reference)
        return false unless config.base_configuration_reference

        path = config.base_configuration_reference.real_path
        update_xcconfig_build_setting_file(path, build_setting, value, {})
      end

      def self.update_xcconfig_build_setting_file(path, build_setting, value, visited)
        path = path.to_s
        expanded_path = File.expand_path(path)
        return false if visited[expanded_path]

        visited[expanded_path] = true
        return false unless File.exist?(path)

        content = File.read(path)
        updated = false
        in_block_comment = false

        new_content = content.each_line.map do |line|
          line_ending = line[/\r?\n\z/] || ""
          line_without_ending = line.chomp
          active_line, in_block_comment = uncomment_xcconfig_line(line_without_ending, in_block_comment)

          # Match against the comment-stripped active_line so lines inside block comments
          # are never modified. The trailing comment/suffix is preserved by slicing
          # line_without_ending from the position just after the matched value.
          if active_line =~ xcconfig_build_setting_regex(build_setting)
            current_value = $4.rstrip
            next line if current_value == value

            trailing = line_without_ending[("#{$1}#{$2}#{$3}#{$4}").length..]
            updated = true
            "#{$1}#{$2}#{$3}#{value}#{trailing}#{line_ending}"
          else
            line
          end
        end.join

        File.write(path, new_content) if updated

        includes_updated = false
        xcconfig_include_paths(content, path).each do |include_path|
          include_updated = update_xcconfig_build_setting_file(include_path, build_setting, value, visited)
          includes_updated ||= include_updated
        end

        updated || includes_updated
      end

      def self.xcconfig_include_paths(content, path)
        in_block_comment = false

        content.each_line.map do |line|
          line_without_ending = line.chomp
          active_line, in_block_comment = uncomment_xcconfig_line(line_without_ending, in_block_comment)
          include = active_line.match(/^\s*#include\??\s*"(.+)"/)
          next unless include

          include_path = include[1]
          include_path = "#{include_path}.xcconfig" if File.extname(include_path).empty?
          File.expand_path(include_path, File.dirname(path))
        end.compact
      end

      def self.uncomment_xcconfig_line(line, in_block_comment)
        active_line = +""
        index = 0

        while index < line.length
          if in_block_comment
            block_comment_end = line.index("*/", index)
            return [active_line, true] unless block_comment_end

            index = block_comment_end + 2
            in_block_comment = false
          else
            line_comment_start = line.index("//", index)
            block_comment_start = line.index("/*", index)

            if line_comment_start && (!block_comment_start || line_comment_start < block_comment_start)
              active_line << line[index...line_comment_start]
              return [active_line, false]
            elsif block_comment_start
              active_line << line[index...block_comment_start]
              index = block_comment_start + 2
              in_block_comment = true
            else
              active_line << line[index..-1]
              return [active_line, false]
            end
          end
        end

        [active_line, in_block_comment]
      end

      def self.xcconfig_build_setting_regex(build_setting)
        %r{^(\s*)(#{Regexp.escape(build_setting)}(?:\[[^\]]+\])*)(\s*=\s*)(.*?)(\s*(?://.*|/\*.*\*/)?$)}
      end

      def self.matching_build_setting_keys(build_settings, build_setting)
        build_settings.keys.select do |key|
          key.to_s == build_setting || key.to_s.start_with?("#{build_setting}[")
        end
      end
    end
  end
end
