require_relative '../helper'
require_relative '../globals'

module Fastlane
  # Adds all the necessary emojis (obv)
  #
  class InspectorReporter
    NUMBER_OF_ISSUES_INLINE = 3

    # Called just as the investigation has begun.
    def inspector_started_query(query, inspector)
      puts("")
      puts("Looking for related GitHub issues on #{inspector.repo_owner}/#{inspector.repo_name}...")
      puts("Search query: #{query}") if FastlaneCore::Globals.verbose?
      puts("")
    end

    # Called once the inspector has received a report with more than one issue.
    def inspector_successfully_received_report(report, inspector)
      report.issues[0..(NUMBER_OF_ISSUES_INLINE - 1)].each { |issue| print_issue_full(issue) }

      if report.issues.count > NUMBER_OF_ISSUES_INLINE
        report.url.sub!('\'', '%27')
        puts("and #{report.total_results - NUMBER_OF_ISSUES_INLINE} more at: #{report.url}")
        puts("")
      end

      print_open_link_hint
    end

    # Called once the report has been received, but when there are no issues found.
    def inspector_received_empty_report(report, inspector)
      puts("Found no similar issues. To create a new issue, please visit:")
      puts("https://github.com/#{inspector.repo_owner}/#{inspector.repo_name}/issues/new")
      puts("Run `fastlane env` to append the fastlane environment to your issue")
    end

    # Called when there have been networking issues in creating the report.
    def inspector_could_not_create_report(error, query, inspector)
      puts("Could not access the GitHub API, you may have better luck via the website.")
      puts("https://github.com/#{inspector.repo_owner}/#{inspector.repo_name}/search?q=#{query}&type=Issues&utf8=✓")
      puts("Error: #{error.name}")
    end

    private

    def print_issue_full(issue)
      resolved = issue.state == 'closed'
      status = (resolved ? issue.state.green : issue.state.red)

      puts("➡️  #{issue.title.yellow}")
      puts("    #{issue.html_url} [#{status}] #{issue.comments} 💬")
      puts("    #{Time.parse(issue.updated_at).to_pretty}")
      puts("")
    end

    def print_open_link_hint(newline = false)
      puts("") if newline
      puts("🔗  You can ⌘ + double-click on links to open them directly in your browser.") if FastlaneCore::Helper.mac?
    end
  end
end
