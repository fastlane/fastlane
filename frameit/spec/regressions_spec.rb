require 'imatcher'

describe Frameit do
  describe 'Regressions', :focus do
    let(:matcher) { Imatcher::Matcher.new }

    def path(path)
      "./frameit/spec/fixtures/regressions/#{path}"
    end

    before :each do
      #FastlaneCore::Globals.verbose = true
      allow(Frameit::FrameDownloader).to receive(:templates_path).and_return(path('devices'))
    end

    describe 'a short text' do
      it 'generates the proper image' do
        Frameit::Runner.new.run(path('short-title'), nil, Platform::IOS)

        expect(matcher.compare(
          path('short-title/fr-FR/iPhone 7 Plus-screenshot_expectation_framed.png'),
          path('short-title/fr-FR/iPhone 7 Plus-screenshot_framed.png'),
          ).match?).to be_truthy
      end
    end

    describe 'apostrophes' do
      it 'generates the proper image' do
        Frameit::Runner.new.run(path('apostrophes'), nil, Platform::IOS)

        expect(matcher.compare(
          path('apostrophes/fr-FR/iPhone 7 Plus-apostrophes_expectation_framed.png'),
          path('apostrophes/fr-FR/iPhone 7 Plus-apostrophes_framed.png')
          ).match?).to be_truthy

        expect(matcher.compare(
          path('apostrophes/fr-FR/iPhone 7 Plus-apostrophes_expectation_framed.png'), # Same fixture as above
          path('apostrophes/fr-FR/iPhone 7 Plus-escaped-apostrophes_framed.png')
          ).match?).to be_truthy
      end
    end
  end
end