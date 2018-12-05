require_relative 'module'

module Scan
  class TestResultParser
    def parse_result(output)
      # e.g. ...<testsuites tests='2' failures='1'>...
      matched = output.scan(/<testsuites\b(?=[^<>]*\s+tests='(\d+)')(?=[^<>]*\s+failures='(\d+)')[^<>]+>/)

      if matched && matched.length == 1 && matched[0].length == 2
        tests = matched[0][0].to_i
        failures = matched[0][1].to_i

        return {
          tests: tests,
          failures: failures
        }
      else
        UI.error("Couldn't parse the number of tests from the output")
        return {
          tests: 0,
          failures: 0
        }
      end
    end
  end
end
