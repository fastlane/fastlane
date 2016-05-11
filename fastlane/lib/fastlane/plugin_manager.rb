module Fastlane
  class PluginManager
    GEMFILE_NAME = "FastlaneGemfile"

    def gemfile_path
      File.join(FastlaneFolder.path, GEMFILE_NAME)
    end

    def gemfile_content
      return File.read(gemfile_path) if File.exist?(gemfile_path)
      nil
    end

    def add_dependency(plugin_name)
      content = gemfile_content || 'source "https://rubygems.org"'
      content += "\ngem '#{plugin_name}'"
      File.write(gemfile_path, content)
    end

    def install_dependencies
      Dir.chdir(FastlaneFolder.path) do
        ENV["BUNDLE_GEMFILE"] = gemfile_path # TODO: move that to a block to auto-remove this value
        puts `bundle install`
      end
    end

    def update_dependencies
      Dir.chdir(FastlaneFolder.path) do
        ENV["BUNDLE_GEMFILE"] = gemfile_path # TODO: move that to a block to auto-remove this value
        puts `bundle update`
      end
    end
  end
end