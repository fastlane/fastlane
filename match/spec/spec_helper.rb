RSpec::Matchers.define(:a_configuration_matching) do |expected|
  match { |actual| actual.values == expected.values }
end

def before_each_match
  ENV['DELIVER_USER'] = 'flapple@krausefx.com'
  ENV['DELIVER_PASSWORD'] = 'so_secret'
end
