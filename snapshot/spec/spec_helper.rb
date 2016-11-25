# Loading the XCode Project is really slow (>1 second)
# fake it out for tests
def fake_out_xcode_project_loading
  fake_result = <<-EOS
Information about project "Example":
    Targets:
        Example
        ExampleUITests
    Build Configurations:
        Debug
        Release
    If no build configuration is specified and -scheme is not passed then "Release" is used.
    Schemes:
        Example
        ExampleUITests
EOS
  allow_any_instance_of(FastlaneCore::Project).to receive(:raw_info).and_return fake_result
end

# Executes the provided block after adjusting the ENV to have the
# provided keys and values set as defined in hash. After the block
# completes, restores the ENV to its previous state.
def with_env_values(hash)
  old_vals = ENV.select { |k, v| hash.include?(k) }
  hash.each do |k, v|
    ENV[k] = hash[k]
  end
  yield
ensure
  hash.each do |k, v|
    ENV.delete(k) unless old_vals.include?(k)
    ENV[k] = old_vals[k]
  end
end
