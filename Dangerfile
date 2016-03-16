warn("Big PR") if lines_of_code > 500

if (pr_body.to_s + pr_title.to_s).include?("WIP")
  warn("Pull Request is Work in Progress")
end

if pr_body.length < 5
  warn "Please provide a changelog summary in the Pull Request description @#{pr_author}"
end

org = ENV["CIRCLE_PROJECT_USERNAME"] || "fastlane"
proj = ENV["CIRCLE_PROJECT_REPONAME"] || "fastlane"
build_number = ENV["CIRCLE_BUILD_NUM"]
circle_token = ENV["CIRCLE_TOKEN"]

artifacts_url = "https://circleci.com/api/v1/project/#{org}/#{proj}/#{build_number}/artifacts?circle-token=#{circle_token}"
require 'open-uri'
require 'json'

artifacts = JSON.parse(open(artifacts_url).read)
fail("Could not find test artifacts") if artifacts.count == 0

artifacts.each do |current|
  rspec_url = current["url"]
  rspec = JSON.parse(open(rspec_url).read)
  rspec["examples"].each do |current_test|
    next if current_test["status"] == "passed"

    message = current_test["exception"]["message"].strip.gsub(/\n+/, "").gsub(/\\t+/, "").gsub(/\\n+/, "")[0..40]
    error_message = "#{current_test["full_description"]}: #{message}"
    puts error_message
    fail(error_message)
  end
end
