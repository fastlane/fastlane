module Precheck
  # each attribute on a app version is a single item.
  # for example: .name, .keywords, .description, will all have a single item to represent them
  # which includes their name and a more user-friendly name we can use to print out information
  class ItemToCheck
    attr_accessor :item_name
    attr_accessor :friendly_name
    attr_accessor :is_optional

    def initialize(item_name, friendly_name, is_optional = false)
      @item_name = item_name
      @friendly_name = friendly_name
      @is_optional = is_optional
    end

    def item_data
      not_implemented(__method__)
    end

    def inspect
      "#{self.class}(friendly_name: #{@friendly_name}, data: #{@item_data})"
    end

    def to_s
      "#{self.class}: #{item_name}: #{friendly_name}"
    end
  end

  # if the data point we want to check is a text field (like 'description'), we'll use this object to encapsulate it
  # this includes the text, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class TextItemToCheck < ItemToCheck
    attr_accessor :text

    def initialize(text, item_name, friendly_name, is_optional = false)
      @text = text
      super(item_name, friendly_name, is_optional)
    end

    def item_data
      return text
    end
  end

  class XcodeProjectItemToCheck < ItemToCheck
    attr_accessor :project_path
    attr_accessor :target_name
    attr_accessor :configuration

    def expand_env(str)
      str.gsub(/\$\(([a-zA-Z_][a-zA-Z0-9_]*\))|\$\({\g<1>}|%\g<1>%/) { ENV[$1] }
    end

    def get_full_path(relative_path)
      return File.join(@project.path, '..', expand_env(relative_path))
    end

    def initialize(project_path, target_name, configuration, item_name, friendly_name, is_optional = false)
      @project_path = project_path
      @target_name = target_name
      @configuration = configuration
      super(item_name, friendly_name, is_optional)

      @project = Xcodeproj::Project.open(@project_path)
    end

    def project
      return @project
    end

    def google_service_plist
      google_service_plist_entry = @project.files.select { |x| x.path.end_with? 'GoogleService-Info.plist' }[0]
      if google_service_plist_entry.nil?
        return nil
      end

      return Xcodeproj::Plist.read_from_path(get_full_path(google_service_plist_entry.path))
    end

    def podfile_includes?(pod_name)
      podfile_path = File.join(File.dirname(@project_path), "Podfile.lock")
      return nil unless File.exist?(podfile_path)
      content = File.read(podfile_path)
      return content.include?(pod_name)
    end

    def target
      return @project.native_targets.detect { |target| target.name == @target_name }
    end

    def configuration
      return nil if target.nil?
      return target.build_configurations.detect { |configuration| configuration .name = @configuration }
    end

    def info_plist
      return nil if configuration.nil?
      infoplist_file = configuration.build_settings['INFOPLIST_FILE']

      return nil if infoplist_file.nil?

      return Xcodeproj::Plist.read_from_path(get_full_path(infoplist_file))
    end

    def entitlements
      return nil if configuration.nil?

      entitlements_file = configuration.build_settings['CODE_SIGN_ENTITLEMENTS']
      if entitlements_file.nil?
        return nil
      end

      return Xcodeproj::Plist.read_from_path(get_full_path(entitlements_file))
    end

    def item_data
      return self
    end
  end

  # if the data point we want to check is a URL field (like 'marketing_url'), we'll use this object to encapsulate it
  # this includes the url, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class URLItemToCheck < ItemToCheck
    attr_accessor :url

    def initialize(url, item_name, friendly_name, is_optional = false)
      @url = url
      super(item_name, friendly_name, is_optional)
    end

    def item_data
      return url
    end
  end
end
