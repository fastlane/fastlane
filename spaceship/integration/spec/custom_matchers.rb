require 'diff_matcher'
require 'multi_json'

RSpec::Matchers.define :match_apple_ten_char_id do |example_path|
  match do |actual|
    @opts = { color_enabled: RSpec.configuration.color_enabled? }
    @difference = DiffMatcher::Difference.new(/^[a-zA-Z0-9]{10}$/, actual, @opts)
    @difference.matching?
  end

  failure_message do |model|
    @difference.to_s
  end
end

RSpec::Matchers.define :match_udid do |example_path|
  match do |actual|
    @opts = { color_enabled: RSpec.configuration.color_enabled? }
    @difference = DiffMatcher::Difference.new(/^[a-fA-F0-9]{40}$/, actual, @opts)
    @difference.matching?
  end

  failure_message do |model|
    @difference.to_s
  end
end

EXAMPLE_MATCHERS = {
  'number' => ->(arg) { arg.kind_of? Fixnum },
  'anything-or-empty' => ->(arg) { /.*/ || arg.nil? },
  'apple-app-id' => /^[A-Z0-9]{10}$/,
  'boolean' => ->(arg) { arg.kind_of?(TrueClass) || arg.kind_of?(FalseClass) },
  'email' => /^[^@]+@\w+.\w+$/,
  'text' => /.+/,
  'anything' => /.*/,
  'url' => %r{http[s]?://.*}
}.freeze

#
# Fuzzy match a JSON file at `example_path` based on matcher rules used as
# values. Possible matchers are defined in EXAMPLE_MATCHERS, and are prefixed
# with a $ when used. Values not beginning with a $ are matched exactly.
#
# Here's an example match pattern:
#
# {
#   "title": "A Tale of Two Cities",
#   "price": "$number",
#   "author": "/Dickens/",
#   "SKUs": ["$number", "$number", "$number"],
#   "description": {
#     "summary": "Two cities or something",
#     "best_quote": "/it was the best/"
#   }
# }
#
RSpec::Matchers.define :match_example do |example_path|
  def expectify(arg)
    case arg
    when /^\$(.*)/ then EXAMPLE_MATCHERS[$1]
    when %r{^/(.*)/$} then Regexp.new($1)
    when Array then arg.map {|el| expectify(el)}
    when Hash then {}.tap {|h| arg.each {|k, v| h[k] = expectify(v) } }
    else arg
    end
  end

  # JSON stuff is all strings, but params from Ruby can contain symbols
  def deep_stringify(hsh)
    hsh.each do |key, value|
      if value.kind_of?(Hash)
        deep_stringify(value)
      elsif value.kind_of?(Symbol)
        hsh.delete[key]
        hsh[key.to_s] = value.to_s
      end
    end

    hsh
  end

  match do |actual|
    expected = File.read(File.join(File.expand_path("../../", __FILE__), '/', example_path))

    parsed_hash = MultiJson.load(expected)
    # We have a special section called "path_params" so it's clear what params are passed
    # in the URL path (ids and such) rather than as query params.
    if parsed_hash['$path_params']
      parsed_hash.merge!(parsed_hash.delete('$path_params'))
    end

    actual_hash = if actual.kind_of?(Hash)
                    deep_stringify(actual)
                  else
                    MultiJson.load(actual.body)
                  end

    expected_hash = expectify(parsed_hash)

    @opts = { color_enabled: RSpec.configuration.color_enabled? }
    @difference = DiffMatcher::Difference.new(expected_hash, actual_hash, @opts)
    @difference.matching?
  end

  failure_message do |model|
    @difference.to_s
  end
end
