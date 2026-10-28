require "json"

# Ruby warnings recorded by spec/spec_helper.rb under FASTLANE_SPEC_WARNINGS, as Markdown:
# one row per location, fastlane's own code first, then the gems it uses.
def warnings_summary(dir = ENV.fetch("FASTLANE_SPEC_WARNINGS", "spec_warnings"))
  root = "#{Dir.pwd}/"
  counts = Hash.new(0)
  Dir[File.join(dir, "*.jsonl")].each do |file|
    File.foreach(file) do |line|
      warning = JSON.parse(line)
      location, text = warning["message"].lines.first.chomp.split(": warning: ", 2)
      counts[[location.delete_prefix(root), warning["category"] || "-", text]] += 1
    end
  end
  ours, others = counts.sort.partition { |(location, _, _), _| !location.start_with?("/", "vendor/") }
  others = others.map { |(location, category, text), count| [[location.sub(%r{\A.*/gems/}, ""), category, text], count] }
  ["## Ruby warnings", "",
   "#{ours.size} in fastlane's code, #{others.size} elsewhere (distinct locations; counts are occurrences).", "",
   *warnings_table("fastlane", ours), *warnings_table("Gems and Ruby", others)].join("\n")
end

def warnings_table(title, rows)
  return [] if rows.empty?
  ["### #{title}", "", "| Location | Category | Warning | Count |", "|---|---|---|--:|",
   *rows.map { |(location, category, text), count| "| `#{location}` | #{category} | #{text.gsub('|', '\|')} | #{count} |" }, ""]
end

desc("Print the Ruby warnings recorded by the last run with FASTLANE_SPEC_WARNINGS, and add them to the GitHub Actions job summary")
task(:warnings_summary) do
  summary = warnings_summary
  puts(summary)
  File.write(ENV["GITHUB_STEP_SUMMARY"], summary, mode: "a") if ENV["GITHUB_STEP_SUMMARY"]
end
