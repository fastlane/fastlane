describe Fastlane do
  describe Fastlane::SwiftFastlaneAPIGenerator do
    describe '#generate_lanefile_parsing_functions' do
      let(:generator) { Fastlane::SwiftFastlaneAPIGenerator.new(target_output_path: 'swift') }

      it 'declares the parse helpers as public so SwiftPM consumers can read return values from custom Ruby actions' do
        output = generator.generate_lanefile_parsing_functions

        expect(output).to include('public func parseArray(fromString: String, function: String = #function) -> [String] {')
        expect(output).to include('public func parseDictionary(fromString: String, function: String = #function) -> [String : String] {')
        expect(output).to include('public func parseDictionary(fromString: String, function: String = #function) -> [String : Any] {')
      end

      it 'keeps the internal helper non-public' do
        output = generator.generate_lanefile_parsing_functions

        expect(output).to include('func parseDictionaryHelper(')
        expect(output).not_to include('public func parseDictionaryHelper(')
      end
    end
  end
end
