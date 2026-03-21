require 'json'
require 'yaml'

def load_fastlane_members
  team_path = File.expand_path('../team.json', __dir__)
  data = JSON.parse(File.read(team_path))
  members = data.keys.map { |u| u.to_s.downcase }
  members << 'fastlane-bot'
  members.uniq.freeze
end

def load_tool_labels
  labeler_path = File.expand_path('../.github/labeler.yml', __dir__)
  yaml = YAML.safe_load(File.read(labeler_path)) || {}
  tool_labels = yaml.keys.grep(/^tool: /)
  tool_labels.uniq.freeze
end

FASTLANE_MEMBERS = load_fastlane_members
ALL_TOOL_LABELS = load_tool_labels

QUERY_DAYS = (ENV["DAYS"] || 30).to_i
SECONDS_PER_DAY = 60 * 60 * 24
GITHUB_TOKEN = ENV['GITHUB_SCRIPT_TOKEN'] || ENV['FL_GITHUB_RELEASE_API_TOKEN']

def labels_for_issue(issue)
  labels =
    if issue.respond_to?(:labels)
      issue.labels
    else
      issue['labels']
    end
  labels.map do |label|
    if label.respond_to?(:name)
      label.name
    else
      begin
        label[:name]
      rescue
        nil
      end || label['name']
    end
  end
end

def convert_time(issue, key)
  value =
    if issue.respond_to?(key)
      issue.send(key)
    else
      issue[key] || issue[key.to_s]
    end

  case value
  when Time
    value.utc
  when String
    DateTime.iso8601(value).to_time.utc
  end
end

def colorized_row(row)
  colorized_row = row.dup
  colorized_row[3] = colorized_row[3].to_s.send(colorized_row[3] > 0 ? :red : :green)
  colorized_row
end

desc("Display issue opening and closing statistics from GitHub")
task(:issue_stats) do
  require 'date'
  require 'octokit'
  require 'terminal-table'
  require 'colored'

  raise "Please set GITHUB_SCRIPT_TOKEN in your environment with a GitHub personal access token value".red if GITHUB_TOKEN.to_s.empty?

  QUERY_START_TIME = (Time.now.utc - (QUERY_DAYS * SECONDS_PER_DAY)).freeze
  puts("Fetching GitHub issues...")

  # Fetch only issues updated within the query time period to keep our GitHub request count reasonable
  since = QUERY_START_TIME.strftime("%Y-%m-%dT%H:%M:%SZ")
  client = Octokit::Client.new(access_token: GITHUB_TOKEN)
  client.auto_paginate = true
  begin
    all_issues_since = client.list_issues('fastlane/fastlane', state: 'all', sort: 'updated', direction: 'desc', per_page: 100, since: since)
  rescue Octokit::Error => e
    raise "GitHub API error while fetching issues: #{e.message}"
  end
  all_issues_since = all_issues_since.to_a
  all_issues_since.reject! do |issue|
    user_login = if issue.respond_to?(:user) && issue.user
                   issue.user.login
                 else
                   issue.dig('user', 'login')
                 end
    FASTLANE_MEMBERS.include?(user_login.to_s.downcase)
  end

  issues_by_labels = {}

  all_issues_since.each do |issue|
    labels = labels_for_issue(issue).compact & ALL_TOOL_LABELS
    labels << 'unlabeled'.yellow if labels.empty?

    labels.each do |label|
      issues_by_labels[label] ||= []
      issues_by_labels[label] << issue
    end
  end

  issue_counts_by_label = issues_by_labels.map do |label, issues|
    return [label, 0, 0, 0] unless issues

    opened_issues = issues.select do |issue|
      t = convert_time(issue, 'created_at')
      t && t > QUERY_START_TIME
    end.count
    closed_issues = issues.select do |issue|
      closed_time = convert_time(issue, 'closed_at')
      closed_time && closed_time > QUERY_START_TIME
    end.count
    netnet = opened_issues - closed_issues

    [label, opened_issues, closed_issues, netnet]
  end

  # Sort by the last column, "Net" so that the projects with the most unclosed issues are at the top
  sorted_issues = issue_counts_by_label.sort_by { |a| a[3] }.reverse
  pretty_issues = sorted_issues.map { |issue_row| colorized_row(issue_row) }

  totals = issue_counts_by_label.each_with_object(['total', 0, 0, 0]) do |row, total_row|
    (1..3).each { |i| total_row[i] += row[i] }
  end

  table = Terminal::Table.new(title: "Issue statistics over the past #{QUERY_DAYS} days".green,
                              headings: %w[Labels Opened Closed Net],
                              rows: pretty_issues)
  table.add_separator
  table.add_row(colorized_row(totals))
  puts(table)
end
