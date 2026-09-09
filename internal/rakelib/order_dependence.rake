ORDER_DEPENDENT_SPECS = "internal/order_dependent_specs.md".freeze

desc("Run only the specs known to be order dependent, in a random order")
task(:test_order_dependent) do
  # The manifest is the markdown working list, so the table and the list it is
  # generated from cannot drift apart. Paths live in its single ```text block.
  block = File.read(ORDER_DEPENDENT_SPECS)[/^```text\n(.*?)^```/m, 1]
  raise "No spec list found in #{ORDER_DEPENDENT_SPECS}" if block.nil?

  files = block.lines.map(&:strip).reject(&:empty?)
  missing = files.reject { |file| File.exist?(file) }
  raise "Listed in #{ORDER_DEPENDENT_SPECS} but missing: #{missing.join(', ')}" unless missing.empty?

  # A different subset means a different ordering, so this samples a context the
  # full run never produces. It is a sampler rather than a gate: green here does
  # not mean the full suite is order independent.
  args = ENV["RSPEC_ARGS"] || "--order random"
  sh("rspec #{files.join(' ')} --format progress #{args}")
end
