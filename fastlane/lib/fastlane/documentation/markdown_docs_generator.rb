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
      Fastlane::Action::AVAILABLE_CATEGORIES.each { |a| self.categories[readable_category_name(a)] = [] }
      ActionsList.all_actions do |action|
        readable = readable_category_name(action.category)

        self.categories[readable] << action
      end
    end

    def generate!(target_path: "docs/ActionsAuto.md")
      template = File.join(Helper.gem_path('fastlane'), "lib/assets/Actions.md.erb")

      result = ERB.new(File.read(template), 0, '-').result(binding) # http://www.rrn.dk/rubys-erb-templating-system
      puts result

      File.write(target_path, result)
      UI.success(target_path)
    end

    private

    def readable_category_name(category_symbol)
      case category_symbol
      when :misc
        "Misc"
      when :source_control
        "Source Control"
      when :notifications
        "Notifications"
      when :testing
        "Testing"
      when :building
        "Building"
      when :screenshots
        "Screenshots"
      when :project
        "Project"
      when :beta
        "Beta"
      when :production
        "Releasing your app"
      else
        category_symbol.to_s.capitalize
      end
    end
  end
end
