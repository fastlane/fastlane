module Fastlane
  class ErbTemplateHelper
    require "erb"
    def self.load(template_name)
      path = "#{Helper.gem_path('fastlane')}/lib/assets/#{template_name}.erb"
      load_from_path(path)
    end

    def self.load_from_path(template_filepath)
      unless File.exist?(template_filepath)
        raise "Could not find Template at path '#{template_filepath}'".red
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
