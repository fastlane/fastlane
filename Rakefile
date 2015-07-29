require "bundler/gem_tasks"
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec
RuboCop::RakeTask.new
