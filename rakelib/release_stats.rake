RED_COMMIT_COUNT = 5
RED_DAY_COUNT = 14

def should_row_be_red?(row)
  row[1] > RED_COMMIT_COUNT || (row[2] > RED_DAY_COUNT && row[1] > 0)
end

def colorize_rows(rows)
  rows.map do |row|
    if should_row_be_red?(row)
      row.map { |item| item.to_s.red }
    else
      row.map(&:to_s)
    end
  end
end

def sort_by_commit_count(rows)
  rows.sort_by! { |row| row[1].to_i }.reverse
end

desc('Print stats about how much time has passed and work has happened since the last release of each tool')
task(:release_stats) do
  require 'date'
  require 'terminal-table'
  require 'colored'
  require 'shellwords'

  `git pull --tags`

  now = Time.now
  rows = []

  GEMS.each do |repo|
    Dir.chdir(repo) do
      last_tag_sha = `git rev-list --tags=#{repo}/* --max-count=1`.chomp
      last_tag_name = `git describe --tags #{last_tag_sha}`.chomp
      commit_count = `git log #{last_tag_name.shellescape}...HEAD --no-merges --oneline .`.chomp.split("\n").count
      commit_time = DateTime.parse(`git show -s --format=%ci #{last_tag_sha}`.chomp).to_time
      days_since_release = (now - commit_time) / SECONDS_PER_DAY

      rows << [repo, commit_count, days_since_release.round]
    end
  end

  rows = sort_by_commit_count(rows)
  rows = colorize_rows(rows)

  puts(Terminal::Table.new(title: 'How Long Since the Last Release?'.green,
                           headings: ['Tool', 'Commits', 'Days'],
                           rows: rows))
end
