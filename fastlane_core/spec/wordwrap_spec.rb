require 'fastlane_core/string_filters'

describe WordWrap do
  context 'wordwrapping will return an array of strings' do
    let(:test_string) { 'some big long string with lots of characters i think there should be more than eighty carachters here!' }

    it 'will return an empty array if the length is zero' do
      result = test_string.wordwrap(0)
      expect(result).to eq([])
    end

    it 'will return an array of strings, each being <= the length passed to wordwrap' do
      wrap_length = 5
      result = test_string.wordwrap(wrap_length)
      string_lengths = result.map(&:length)
      expect(result).to all(be_a(String))
      expect(string_lengths).to all(be <= wrap_length + 1) # The +1 is to consider spaces
    end
  end
end
