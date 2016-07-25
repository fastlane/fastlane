module Fastlane
  class CrashlyticsBetaUi
    def success(text)
      puts text.green
    end

    def message(text)
      puts text
    end

    def input(text)
      UI.input(text)
    end

    def confirm(text)
      UI.confirm(text)
    end

    def ask(text)
      UI.ask(text)
    end

    def header(text)
      i = text.length + 8
      success("-" * i)
      success("--- " + text + " ---")
      success("-" * i)
    end

    def important(text)
      puts text.yellow
    end
  end
end
