module Fastlane
  class PluginGeneratorUI
    def message(text)
      puts text
    end

    def input(text)
      UI.input(text)
    end

    def confirm(text)
      UI.confirm(text)
    end
  end
end
