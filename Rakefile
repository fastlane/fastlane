require 'bundler/gem_tasks'
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each(&method(:import))

desc 'Execute RuboCop static code analysis'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w(bin lib)
  t.fail_on_error = false
end

task default: :spec
