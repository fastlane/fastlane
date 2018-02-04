
if defined? RSpec # otherwise fails on non-live environments
  SPEC_REQUIRES = ["--require spec_helper"].freeze
  INTEGRATION_REQUIRES = [
    "--require ./integration/example_matcher.rb",
    "--require ./integration/integration_helper.rb"
  ].freeze

  task(:spec).clear
  desc("Run all specs and all the integration tests")
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = (SPEC_REQUIRES + INTEGRATION_REQUIRES).join(' ')
    t.pattern = './{spec,integration}/**/*_spec.rb'
  end

  namespace(:spec) do
    desc("Run the integration tests that hit Apple's Services")
    RSpec::Core::RakeTask.new(:integration) do |t|
      t.rspec_opts = INTEGRATION_REQUIRES.join(' ')
      t.pattern = './integration/**/*_spec.rb'
    end

    desc("Run the specs that used mocked responses")
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.rspec_opts = SPEC_REQUIRES.join(' ')
      t.pattern = './spec/**/*_spec.rb'
    end
  end
end
