require 'active_support/core_ext/string/strip'

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
  raise_error FastlaneCore::Interface::FastlaneError
end
