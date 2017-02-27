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

    def self.render(template, template_vars_hash)
      Fastlane::ErbalT.new(template_vars_hash).render(template)
    end
  end
  class ErbalT < OpenStruct
    def render(template)
      ERB.new(template).result(binding)
    end
  end
end
