#!/usr/bin/env ruby
file = File.join(__dir__, "..", "Gemfile.lock")
lines = File.read(file).split("\n")
idx = lines.index { |l| l == "BUNDLED WITH" }
puts lines[idx + 1].strip
