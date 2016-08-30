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
        readable = readable_category_name(action.category)
        self.categories[readable] ||= []
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
      else
        category_symbol.to_s.capitalize
      end
    end
  end
end
