module Attach
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGenerator
    class << self
      def generate
        parts = ["xcodebuild -exportArchive"]
        parts += options
        parts += pipe

        parts
      end

      def options
        options = []

        app_path = Dir[BuildCommandGenerator.build_path + "**/*.app"] # TODO: necessary?
        raise "Could not find app in #{BuildCommandGenerator.build_path}" if app_path.count == 0
        ErrorHandler.handle_empty_archive unless app_path

        options << "-archivePath '#{BuildCommandGenerator.archive_path}'"
        options << "exportFormat ipa"
        options << "-exportPath '#{ipa_path}'"

        options
      end

      def pipe
        [""]
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Attach.project.app_name}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.build_path + "**/*.dSYM"].last
      end
    end
  end
end
