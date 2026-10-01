describe FastlaneCore::Interface::FastlaneShellError do
  it 'defaults to not showing github issues' do
    error = FastlaneCore::Interface::FastlaneShellError.new
    expect(error.show_github_issues).to be(false)
  end

  it 'respects the show_github_issues option when false' do
    error = FastlaneCore::Interface::FastlaneShellError.new(show_github_issues: false)
    expect(error.show_github_issues).to be(false)
  end

  it 'respects the show_github_issues option when true' do
    error = FastlaneCore::Interface::FastlaneShellError.new(show_github_issues: true)
    expect(error.show_github_issues).to be(true)
  end

  it 'has the correct prefix' do
    error = FastlaneCore::Interface::FastlaneShellError.new
    expect(error.prefix).to eq('[SHELL_ERROR]')
  end
end
