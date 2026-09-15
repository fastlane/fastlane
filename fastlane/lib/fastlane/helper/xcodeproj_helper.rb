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
          return Xcodeproj::Project.open(project_path)
        else
          UI.user_error!("Unable to find Xcode project at #{project_path || xcodeproj_path_or_dir}")
        end
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
