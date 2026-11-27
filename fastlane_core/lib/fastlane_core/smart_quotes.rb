require_relative 'env'

module FastlaneCore
  # Repairs the smart quotes TextEdit writes into Fastfiles, Appfiles and tool configuration files.
  # From https://github.com/orta/danger/blob/master/lib/danger/Dangerfile.rb
  module SmartQuotes
    # @return [String, nil] the warning to print when content was changed
    def self.sanitize!(content, path)
      return nil if FastlaneCore::Env.truthy?("FASTLANE_SKIP_SMART_QUOTES_SANITIZE")
      return nil unless content.tr!('“”‘’‛', %(""'''))

      "Your #{File.basename(path)} has had smart quotes sanitised. " \
        'To avoid issues in the future, you should not use ' \
        'TextEdit for editing it. If you are not using TextEdit, ' \
        'you should turn off smart quotes in your editor of choice. ' \
        'If you use smart quotes on purpose, set FASTLANE_SKIP_SMART_QUOTES_SANITIZE=1 to keep them.'
    end
  end
end
