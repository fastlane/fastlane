require "json"

# Coverage of the last run as Markdown, one row per tool. See fastlane#30289.
def coverage_summary(path = "coverage/coverage.json")
  totals = Hash.new { |hash, tool| hash[tool] = [0, 0] }
  JSON.parse(File.read(path))["coverage"].each do |file, data|
    relevant = data["lines"].grep(Integer)
    totals[file.split("/").first][0] += relevant.count(&:positive?)
    totals[file.split("/").first][1] += relevant.size
  end
  covered, lines = totals.values.transpose.map(&:sum)
  rows = totals.sort.map { |tool, (c, l)| "| #{tool} | #{coverage_percent(c, l)} | #{l} |" }
  ["## Coverage", "", "#{coverage_percent(covered, lines)} of #{lines} lines", "", "| Tool | Coverage | Lines |", "|---|--:|--:|", *rows, ""].join("\n")
end

def coverage_percent(covered, lines)
  format("%.1f%%", 100.0 * covered / lines)
end

desc("Print the coverage of the last run, or add it to the GitHub Actions job summary")
task(:coverage_summary) do
  summary = coverage_summary
  if ENV["GITHUB_STEP_SUMMARY"]
    File.write(ENV["GITHUB_STEP_SUMMARY"], summary, mode: "a")
  else
    puts(summary)
  end
end
