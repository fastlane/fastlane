# Executes the provided block after adjusting the ENV to have the
# provided keys and values set as defined in hash. After the block
# completes, restores the ENV to its previous state.
def with_env_values(hash, &block)
  with_global_key_values(ENV, hash, &block)
end

def with_action_context_values(hash, &block)
  with_global_key_values(Fastlane::Actions.lane_context, hash, &block)
end

def with_global_key_values(global_store, hash)
  old_vals = global_store.select { |k, v| hash.include?(k) }
  hash.each do |k, v|
    global_store[k] = hash[k]
  end
  yield
ensure
  hash.each do |k, v|
    global_store.delete(k) unless old_vals.include?(k)
    global_store[k] = old_vals[k]
  end
end

def raise_fastlane_error
  raise_error(FastlaneCore::Interface::FastlaneError)
end

def raise_fastlane_test_failure
  raise_error(FastlaneCore::Interface::FastlaneTestFailure)
end

# The following methods is taken from activesupport,
#
# https://github.com/rails/rails/blob/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/string/strip.rb
#
# All credit for this method goes to the original authors.
# The code is used under the MIT license.
#
# Strips indentation by removing the amount of leading whitespace in the least indented non-empty line in the whole string
#
def strip_heredoc(str)
  str.gsub(/^#{str.scan(/^[ \t]*(?=\S)/).min}/, "".freeze)
end
