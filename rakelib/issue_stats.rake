QUERY_DAYS = (ENV["DAYS"] || 4).to_i

FASTLANE_MEMBERS = %w(asfalcone chaselatta fastlane-bot hemal i2amsam kimyoutora KrauseFx mfurtak MichaelDoyle mpirri ohwutup samrobbins snatchev vpolouchkine)

ALL_TOOL_LABELS = %w(fastlane fastlane_core deliver snapshot frameit pem sigh produce cert gym pilot credentials_manager spaceship scan supply watchbuild match screengrab)

GITHUB_TOKEN = ENV['GITHUB_SCRIPT_TOKEN'] || ENV['FL_GITHUB_RELEASE_API_TOKEN']

BASE_URL = 'https://api.github.com'.freeze

# Uses the provided Faraday connection and starting URL + params to iteratively
# get all pages worth of items from GitHub
def get_all(conn, url, params)
  items = []
  next_url = url

  loop do
    resp = conn.get do |req|
      req.headers['Authorization'] = "token #{GITHUB_TOKEN}"
      req.url(next_url, params)
    end

    items += JSON.parse(resp.body)

    next_url_match = (resp.headers['Link'] || '').match(/\<(.+)\>; rel="next"/) || []
    next_url = (next_url_match[1] || '').gsub(BASE_URL, '')

    break if next_url.empty?
  end

  items
end

def labels_for_issue(issue)
  issue['labels'].map { |label| label['name'] }
end

def convert_time(issue, key)
  DateTime.iso8601(issue[key]).to_time.utc
end

def colorized_row(row)
  colorized_row = row.dup
  colorized_row[3] = colorized_row[3].to_s.send(colorized_row[3] > 0 ? :red : :green)
  colorized_row
end

desc("Display issue opening and closing statistics from GitHub")
task(:issue_stats) do
  require 'date'
  require 'json'
  require 'faraday'
  require 'terminal-table'
  require 'colored'

  raise "Please set GITHUB_SCRIPT_TOKEN in your environment with a GitHub personal access token value".red if GITHUB_TOKEN.to_s.empty?

  conn = Faraday.new(url: BASE_URL)

  QUERY_START_TIME = (Time.now.utc - (QUERY_DAYS * SECONDS_PER_DAY)).freeze
  puts("Fetching GitHub issues...")

  # Fetch only issues updated within the query time period to keep our GitHub request count reasonable
  since = QUERY_START_TIME.strftime("%Y-%m-%dT%H:%M:%SZ")
  all_issues_since = get_all(conn, "/repos/fastlane/fastlane/issues", state: 'all', sort: 'update', direction: 'desc', per_page: 100, since: since)
  all_issues_since.reject! { |issue| FASTLANE_MEMBERS.include?(issue['user']['login']) }

  issues_by_labels = {}

  all_issues_since.each do |issue|
    labels = labels_for_issue(issue) & ALL_TOOL_LABELS
    labels << 'unlabeled'.yellow if labels.empty?

    labels.each do |label|
      issues_by_labels[label] ||= []
      issues_by_labels[label] << issue
    end
  end

  issue_counts_by_label = issues_by_labels.map do |label, issues|
    return [label, 0, 0, 0] unless issues

    opened_issues = issues.select { |issue| convert_time(issue, 'created_at') > QUERY_START_TIME }.count
    closed_issues = issues.select { |issue| issue['closed_at'] && (convert_time(issue, 'closed_at') > QUERY_START_TIME) }.count
    netnet = opened_issues - closed_issues

    [label, opened_issues, closed_issues, netnet]
  end

  # Sort by the last column, "Net" so that the projects with the most unclosed issues are at the top
  # rubocop: disable Performance/CompareWithBlock
  sorted_issues = issue_counts_by_label.sort { |row_1, row_2| row_1[3] <=> row_2[3] }.reverse
  # rubocop: enable Performance/CompareWithBlock
  pretty_issues = sorted_issues.map { |issue_row| colorized_row(issue_row) }

  totals = issue_counts_by_label.each_with_object(['total', 0, 0, 0]) do |row, total_row|
    (1..3).each { |i| total_row[i] += row[i] }
  end

  table = Terminal::Table.new(title: "Issue statistics over the past #{QUERY_DAYS} days".green,
                              headings: ['Labels', 'Opened', 'Closed', 'Net'],
                              rows: pretty_issues)
  table.add_separator
  table.add_row(colorized_row(totals))
  puts(table)
end
