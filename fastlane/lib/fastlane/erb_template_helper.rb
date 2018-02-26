module Fastlane
  class ErbTemplateHelper
    require "erb"
    def self.load(template_name)
      path = "#{Fastlane::ROOT}/lib/assets/#{template_name}.erb"
      load_from_path(path)
    end

    def self.load_from_path(template_filepath)
      unless File.exist?(template_filepath)
        UI.user_error!("Could not find template at path '#{template_filepath}'")
      end
      File.read(template_filepath)
    end

    def self.render(template, template_vars_hash, trim_mode = nil)
      Fastlane::ErbalT.new(template_vars_hash, trim_mode).render(template)
    end
  end
  class ErbalT < OpenStruct
    def initialize(hash, trim_mode = nil)
      super(hash)
      @trim_mode = trim_mode
    end

    def render(template)
      ERB.new(template, nil, @trim_mode).result(binding)
    end
  end
end
