require 'ios_deploy_kit'

module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end