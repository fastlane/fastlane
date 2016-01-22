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

    it "properly parses the xcodebuild output" do
      output = "<?xml version='1.0' encoding='UTF-8'?>
        <testsuites tests='2' failures='1'/>"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq(
        tests: 2,
        failures: 1
      )
    end
  end
end
