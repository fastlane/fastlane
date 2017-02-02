describe 'CHANGELOG.md' do
  def error_message(bad_lines)
    "The following lines in the CHANGELOG.md are missing two spaces at the end:\n\n" + bad_lines.join("\n")
  end

  it "ends every entry with two spaces" do
    bad_lines = []
    changelog = File.expand_path('../../CHANGELOG.md', File.dirname(__FILE__))
    File.foreach(changelog).with_index do |line, line_num|
      bad_lines << "#{line_num + 1}: #{line.inspect}" if line.start_with?('* ') && !line.end_with?("  \n")
    end
    expect(bad_lines).to be_empty, error_message(bad_lines)
  end
end
