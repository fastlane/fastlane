module Fastlane
  class PluginGenerator
    def initialize(root_dir)
      @root = root_dir
    end

    def generate
      template('templates/plugins/gemspec.tt', "#{options[:gem_name]}.gemspec")
    end
  end
end
