require_relative 'stubbing.rb'

# Commander::Command::Options does not define sane equals behavior,
# so we need this to make testing easier
RSpec::Matchers.define(:match_commander_options) do |expected|
  match { |actual| actual.__hash__ == expected.__hash__ }
end
