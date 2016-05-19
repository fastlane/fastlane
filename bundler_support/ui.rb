require 'io/console'

module BundlerSupport
  class UI
    def message(text)
      puts text
    end

    def indent(text, amount)
      puts text.gsub(/^(?!$)/, ' ' * amount)
    end

    def confirm(message)
      ch = nil
      loop do
        puts message
        ch = STDIN.getch.downcase
        puts ch
        break if ['y', 'n'].include?(ch)
      end
      ch == 'y'
    end
  end
end
