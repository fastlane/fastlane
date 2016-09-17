describe Fastlane::Helper::GradleHelper do
  describe 'parameter handling' do
    it 'stores a shell-escaped version of the gradle_path when constructed' do
      gradle_path = '/fake gradle/path'
      helper = Fastlane::Helper::GradleHelper.new(gradle_path: gradle_path)

      expect(helper.gradle_path).to eq(gradle_path)
      expect(helper.escaped_gradle_path).to eq(gradle_path.shellescape)
    end

    it 'updates a shell-escaped version of the gradle_path when modified' do
      gradle_path = '/fake gradle/path'
      helper = Fastlane::Helper::GradleHelper.new(gradle_path: '/different/when/constructed')
      helper.gradle_path = gradle_path

      expect(helper.gradle_path).to eq(gradle_path)
      expect(helper.escaped_gradle_path).to eq(gradle_path.shellescape)
    end
  end
end
