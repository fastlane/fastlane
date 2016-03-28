module Scan
  class TestResultParser
    def parse_result(output)
      # e.g. ...<testsuites tests='2' failures='1'>...
      matched = output.match(%r{\<testsuites tests='(\d+)' failures='(\d+)'/?\>})

      if matched and matched.length == 3
        tests = matched[1].to_i
        failures = matched[2].to_i

        return {
          tests: tests,
          failures: failures
        }
      else
        UI.error("Couldn't parse the number of tests from the output")
        return {}
      end
    end
  end
end
