warn("Big PR") if lines_of_code > 500

if (pr_body.to_s + pr_title.to_s).include?("WIP")
  warn("Pull Request is Work in Progress")
end

if pr_body.length < 5
  warn "Please provide a changelog summary in the Pull Request description @#{pr_author}"
end

require 'json'

rspec_files = Dir[File.join(ENV["CIRCLE_ARTIFACTS"], "rspec_logs_*.json")]
fail("Could not find test artifacts") if rspec_files.count == 0
rspec_files.each do |current|
  rspec = JSON.parse(File.read(current))

  rspec["examples"].each do |current_test|
    next if current_test["status"] == "passed"

    message = current_test["exception"]["message"].strip.gsub(/\n+/, "").gsub(/\\t+/, "").gsub(/\\n+/, "")[0..40]
    error_message = "#{current_test["full_description"]}: #{message}"
    puts error_message
    fail("<code>#{error_message}</code>")
  end
end
