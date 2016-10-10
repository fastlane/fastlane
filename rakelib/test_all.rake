def for_each_gem
  GEMS.each do |g|
    yield g if block_given?
  end
end

def messages_for_failed_tests(failures_by_gem)
  failures_by_gem.reduce([]) do |memo, (gem_name, failures)|
    memo += failures.map do |f|
      original_file_path = f["file_path"]
      file_path = original_file_path.sub(".", gem_name)
      "#{file_path}:#{f["line_number"]}".red + " # #{f["full_description"]}".cyan
    end
  end
end

def format_failures(failures_by_gem)
  count = 1
  failures_by_gem.reduce([]) do |memo, (gem_name, failures)|
    memo += failures.map do |failure|
      formatted_failure = format_failure(failure, gem_name, count)
      count += 1
      formatted_failure
    end
  end
end

def format_failure(failure, gem_name, count)
  file_path = failure["file_path"].sub(".", "")
  stack_frame = failure["exception"]["backtrace"].detect { |frame| frame.include?(file_path) }
  stack_frame_match = /#{gem_name}#{file_path}:(\d+).*/.match(stack_frame)
  code_line = get_line_from_file(stack_frame_match[1].to_i, "#{gem_name}#{file_path}").strip

  formatted_failure = count == 1 ? "\n" : ""
  formatted_failure += "#{count}) #{failure["full_description"]}\n"
  formatted_failure += "Failure/Error: #{code_line}\n".red
  formatted_failure += "#{failure["exception"]["message"]}".red
  formatted_failure += "# #{stack_frame_match[0]}\n".cyan
end

def bundle_install
  if ENV['CI']
    cache_path = File.expand_path("~/.fastlane_bundle")
    path = " --path=#{cache_path}"
  end

  sh "bundle check#{path} || bundle install#{path} --jobs=4 --retry=3"
end

task :bundle_install_all do
  puts "Fetching dependencies in the root"
  bundle_install

  for_each_gem do |repo|
    Dir.chdir(repo) do
      puts "Fetching dependencies for #{repo}"
      bundle_install
    end
  end
end

def get_line_from_file(line_number, file)
  File.open(file) do |io|
    io.each_with_index do |line, index|
      return line if line_number == index + 1
    end
  end
end

desc "Test all fastlane projects"
task :test_all do
  require 'bundler/setup'
  require 'colored'
  require 'fileutils'
  require 'json'

  exceptions = []
  repos_with_exceptions = []
  rspec_log_file = "rspec_logs.json"

  for_each_gem do |repo|
    box "Testing #{repo}"
    Dir.chdir(repo) do
      FileUtils.rm_f(rspec_log_file)
      begin
        # From https://github.com/bundler/bundler/issues/1424#issuecomment-2123080
        # Since we nest bundle exec in bundle exec
        Bundler.with_clean_env do
          rspec_command_parts = [
            "bundle exec rspec",
            "--format documentation",
            "--format j --out #{rspec_log_file}"
          ]
          if ENV['CIRCLECI']
            output_file = File.join(ENV['CIRCLE_TEST_REPORTS'], 'rspec', "#{repo}-junit.xml")
            rspec_command_parts << "--format RspecJunitFormatter --out #{output_file}"
          end

          sh rspec_command_parts.join(' ')
          sh "bundle exec rubocop"
        end
      rescue => ex
        puts "[[FAILURE]] with repo '#{repo}' due to\n\n#{ex}\n\n"
        exceptions << "#{repo}: #{ex}"
        repos_with_exceptions << repo
      ensure
        if ENV["CIRCLECI"] && ENV["CIRCLE_ARTIFACTS"] && File.exist?(rspec_log_file)
          FileUtils.cp(rspec_log_file, File.join(ENV["CIRCLE_ARTIFACTS"], "rspec_logs_#{repo}.json"))
        end
      end
    end
  end

  failed_tests_by_gem = {}
  example_count = 0
  duration = 0.0

  for_each_gem do |gem_name|
    failed_tests_by_gem[gem_name] = []

    log_file_path = File.join(gem_name, rspec_log_file)
    next unless File.readable?(log_file_path)

    log_json = JSON.parse(File.read(log_file_path))
    tests = log_json["examples"]
    summary = log_json["summary"]

    example_count += summary["example_count"]
    duration += summary["duration"]
    failed_tests_by_gem[gem_name] += tests.select { |r| r["status"] != "passed" }
  end

  failure_messages = messages_for_failed_tests(failed_tests_by_gem)

  puts ("*" * 80).yellow
  box "Testing Summary"
  puts "\nFinished in #{duration.round(3)} seconds"
  puts "#{example_count} examples, #{failure_messages.count} failure(s)".send(failure_messages.empty? ? :green : :red)

  unless failure_messages.empty?
    box "#{exceptions.count} repo(s) with test failures: " + repos_with_exceptions.join(", ")
    puts format_failures(failed_tests_by_gem)
    puts "Failed examples:"
    puts "#{failure_messages.join("\n")}\n"
  end

  if exceptions.empty?
    puts "Success 🚀".green
  else
    box "Exceptions 💣"
    puts "\n" + exceptions.map(&:red).join("\n")
    raise "All tests did not complete successfully. Search for '[[FAILURE]]' in the build logs.".red
  end
end
