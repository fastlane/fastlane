require 'tmpdir'
require 'fileutils'

require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'fastlane_core'

require 'webmock/rspec'

require 'test_commander_program'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!(allow: 'coveralls.io')

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

def stub_commander_runner_args(args)
  runner = Commander::Runner.new(args)
  allow(Commander::Runner).to receive(:instance).and_return(runner)
end
