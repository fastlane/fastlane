module Fastlane
  class MailHelper
    require "erb"
    def self.load_template(template_name)
      path = "#{Helper.gem_path('fastlane')}/lib/assets/#{template_name}.erb"
      raise "Could not find Template at path '#{path}'".red unless File.exist?(path)
      File.read(path)
    end

    def self.render_template(template,template_vars_hash)
      Fastlane::ErbalT.new(template_vars_hash).render(template)
    end

  end
  class ErbalT < OpenStruct
    def render(template)
      ERB.new(template).result(binding)
    end
  end
end
