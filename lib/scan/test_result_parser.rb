module Scan
  class TestResultParser
    def parse_result(output)
      # \nExecuted 1 test, with 0 failures (0 unexpected) in 4.460 (4.461) seconds
      matched = output.match(/Executed (\d+).*with (\d+) failures.* in ([\d\.]+)/)

      if matched.length == 4
        tests = matched[1]
        failures = matched[2]
        duration = matched[3]

        return {
          tests: tests,
          failures: failures,
          duration: duration
        }
      else
        Helper.log.error "Couldn't parse the number of tests from the output".red
        return {}
      end
    end
  end
end
