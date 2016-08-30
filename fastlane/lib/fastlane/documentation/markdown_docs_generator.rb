require 'pry'
module Fastlane
  class MarkdownDocsGenerator
    attr_accessor :categories

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions

      self.work
    end

    def work
      self.categories = {}
      ActionsList.all_actions do |action|
        self.categories['Misc'] ||= []
        self.categories['Misc'] << action
      end
    end

    def generate!(target_path: "docs/ActionsAuto.md")
      template = File.join(Helper.gem_path('fastlane'), "lib/assets/Actions.md.erb")

      result = ERB.new(File.read(template), 0, '-').result(binding) # http://www.rrn.dk/rubys-erb-templating-system
      puts result

      File.write(target_path, result)
      UI.success(target_path)
    end
  end
end
