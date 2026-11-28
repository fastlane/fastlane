module Fastlane
  module Helper
    class AgvtoolHelper
      # agvtool edits these files with sed and exits 0 even when a value breaks them:
      # `new-marketing-version release/1.2.3` leaves project.pbxproj empty
      class DamagedProjectError < FastlaneCore::Interface::FastlaneError; end

      # Runs an agvtool command in folder, and puts the project files back if it left any unreadable
      def self.run(command, folder:)
        require 'xcodeproj'

        files = files_agvtool_edits(folder)
        originals = files.to_h { |path| [path, File.binread(path)] }

        output = Actions.sh(command)

        damaged = files.reject { |path| readable?(path) }
        unless damaged.empty?
          originals.each { |path, content| File.binwrite(path, content) }
          relative = damaged.map { |path| path.delete_prefix("#{File.expand_path(folder)}/") }
          raise DamagedProjectError.new, "agvtool left #{relative.join(', ')} unreadable, so they were put back as they were. agvtool printed: #{output.to_s.strip}"
        end

        output
      end

      def self.files_agvtool_edits(folder)
        folder = File.expand_path(folder)
        projects = Dir[File.join(folder, '*.xcodeproj')]
        info_plists = projects.flat_map do |project_path|
          Xcodeproj::Project.open(project_path).targets.flat_map do |target|
            target.build_configurations.map { |config| config.build_settings['INFOPLIST_FILE'] }
          end
        rescue StandardError
          []
        end

        paths = projects.map { |project_path| File.join(project_path, 'project.pbxproj') }
        paths += info_plists.compact.uniq.map { |plist| File.expand_path(plist.sub(/\A\$[({]SRCROOT[)}]/, '.'), folder) }
        paths.select { |path| File.file?(path) }.uniq
      end

      def self.readable?(path)
        !File.empty?(path) && Xcodeproj::Plist.read_from_path(path).kind_of?(Hash)
      rescue StandardError
        false
      end
    end
  end
end
