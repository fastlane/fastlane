module Fastlane
  class PluginInfo
    attr_reader :plugin_name
    attr_reader :author
    attr_reader :gem_name
<<<<<<< HEAD
    attr_reader :email
    attr_reader :summary
    attr_reader :description

    def initialize(plugin_name, author, email, summary, description)
      @plugin_name = plugin_name
      @author = author
      @email = email
      @summary = summary
      @description = description
=======

    def initialize(plugin_name, author)
      @plugin_name = plugin_name
      @author = author
>>>>>>> 532a9a6fe97ec3038deacb16b2160abcf5ca27d0
    end

    def gem_name
      "#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}#{plugin_name}"
    end

    def require_path
<<<<<<< HEAD
      gem_name.tr('-', '/')
    end

    def actions_path
      File.join(require_path, 'actions')
    end

    def helper_path
      File.join(require_path, 'helper')
    end

    # Used to expose a local binding for use in ERB templating
    #
    # rubocop:disable Style/AccessorMethodName
    def get_binding
      binding
    end
    # rubocop:enable Style/AccessorMethodName

    def ==(other)
      @plugin_name == other.plugin_name &&
      @author == other.author &&
      @email == other.email &&
      @summary == other.summary &&
      @description == other.description
=======
      gem_name.gsub('-', '/')
    end

    # Used to exposed a local binding for use in ERB templating
    def get_binding
      binding
    end

    def ==(other)
      @plugin_name == other.plugin_name &&
      @author == other.author
>>>>>>> 532a9a6fe97ec3038deacb16b2160abcf5ca27d0
    end
  end
end
