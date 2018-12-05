module Fastlane
  class PluginGeneratorUI
    def success(text)
      puts(text.green)
    end

    def message(text)
      puts(text)
    end

    def input(text)
      UI.input(text)
    end

    def confirm(text)
      UI.confirm(text)
    end
  end
end
