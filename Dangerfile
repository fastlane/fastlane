# We generally try to avoid big PRs
warn("Big PR") if git.lines_of_code > 500

# Show a warning for PRs that are Work In Progress
if (github.pr_body + github.pr_title).include?("WIP")
  warn("Pull Request is Work in Progress")
end

# Contributors should always provide a changelog when submitting a PR
if github.pr_body.length < 5
  warn("Please provide a changelog summary in the Pull Request description @#{pr_author}")
end

# We want contributors to create an issue first before submitting a PR
# Exceptions are version bumps
if !github.pr_title.downcase.include?('version bump') &&
   !github.pr_body.include?("https://github.com/fastlane/fastlane/issues/") &&
   github.pr_body.match(/#\d+/).nil?
  warn("Before submitting a Pull Request, please create an issue on GitHub to discuss the change. Please add a link to the issue in the PR body.")
end

# To avoid "PR & Runs" for which tests don't pass, we want to make spec errors more visible
# The code below will run on Circle, parses the results in JSON and posts them to the PR as comment

require 'json'

containing_dir = ENV["CIRCLE_ARTIFACTS"] || "." # for local testing
rspec_files = Dir[File.join(containing_dir, "rspec_logs_*.json")]
rspec_files.each do |current|
  rspec = JSON.parse(File.read(current))

  rspec["examples"].each do |current_test|
    next if current_test["status"] == "passed"

    # The current "example" failed, let's prepare a nice looking error message
    new_line = "<br />"
    border = "<hr />"
    message = current_test["exception"]["message"].strip.gsub(/\n+/, new_line).gsub(/\\t+/, new_line).gsub(/\\n+/, new_line)

    tool_name = current.match(/.*rspec_logs_(.*).json/)[1] # e.g. "rspec_logs_spaceship.json"
    file_path = current_test["file_path"].gsub("./", "#{tool_name}/")
    error_message = "<code>#{file_path}:#{current_test["line_number"]}</code>"
    error_message += border
    error_message += "<pre>#{message}</pre>"

    # We have the test failure, let's pass it to danger
    fail(error_message)
  end
end
