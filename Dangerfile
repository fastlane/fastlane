warn("Big PR") if lines_of_code > 500

if (pr_body.to_s + pr_title.to_s).include?("WIP")
  warn("Pull Request is Work in Progress")
end

if pr_body.length < 5
  warn("Please provide a changelog summary in the Pull Request description @#{pr_author}")
end

unless pr_body.include?("https://github.com/fastlane/fastlane/issues/")
  warn("Before submitting a Pull Request, please create an issue on GitHub to discuss the change. Please add a link to the issue in the PR body.")
end

require 'json'

containing_dir = ENV["CIRCLE_ARTIFACTS"] || "." # for local testing
rspec_files = Dir[File.join(containing_dir, "rspec_logs_*.json")]
rspec_files.each do |current|
  rspec = JSON.parse(File.read(current))

  rspec["examples"].each do |current_test|
    next if current_test["status"] == "passed"

    new_line = "<br />"
    border = "<hr />"
    message = current_test["exception"]["message"].strip.gsub(/\n+/, new_line).gsub(/\\t+/, new_line).gsub(/\\n+/, new_line)

    tool_name = current.match(/.*rspec_logs_(.*).json/)[1] # e.g. "rspec_logs_spaceship.json"
    file_path = current_test["file_path"].gsub("./", "#{tool_name}/")
    error_message = "<code>#{file_path}:#{current_test["line_number"]}</code>"
    error_message += border
    error_message += "<pre>#{message}</pre>"

    fail(error_message)
  end
end
