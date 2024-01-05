describe Scan do
  describe Scan::TestResultParser do
    it "properly parses the xcodebuild output" do
      output = "<?xml version='1.0' encoding='UTF-8'?>
      <testsuites tests='2' failures='1'>
      <testsuite name='appTests' tests='2' failures='1'>
      <testcase classname='appTests' name='testExample'>
      <failure message='((1 == 2 - 4) is true) failed'>appTests/appTests.m:30</failure>
      </testcase>
      <testcase classname='appTests' name='testPerformanceExample' time='0.262'/>
      </testsuite>
      </testsuites>"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq({
        tests: 2,
        failures: 1
      })
    end

    it "properly parses the xcodebuild output when the properties are in a different order" do
      output = "<?xml version='1.0' encoding='UTF-8'?>
      <testsuites failures='1' tests='2'>
      <testsuite name='appTests' tests='2' failures='1'>
      <testcase classname='appTests' name='testExample'>
      <failure message='((1 == 2 - 4) is true) failed'>appTests/appTests.m:30</failure>
      </testcase>
      <testcase classname='appTests' name='testPerformanceExample' time='0.262'/>
      </testsuite>
      </testsuites>"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq(
        tests: 2,
        failures: 1
      )
    end

    it "properly parses the xcodebuild output" do
      output = "<?xml version='1.0' encoding='UTF-8'?>
      <testsuites tests='2' failures='1'/>"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq(
        tests: 2,
        failures: 1
      )
    end

    it "properly parses the xcodebuild output when there are extra properties" do
      output = "<?xml version='1.0' encoding='UTF-8'?>
      <testsuites foo='1' tests='2' bar='3' failures='1' baz='4'>
      <testsuite name='appTests' tests='2' failures='1'>
      <testcase classname='appTests' name='testExample'>
      <failure message='((1 == 2 - 4) is true) failed'>appTests/appTests.m:30</failure>
      </testcase>
      <testcase classname='appTests' name='testPerformanceExample' time='0.262'/>
      </testsuite>
      </testsuites>"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq(
        tests: 2,
        failures: 1
      )
    end

    it "returns early if the xcodebuild output is nil" do
      output = nil

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq(
        tests: 0,
        failures: 0
      )
    end
  end
end
