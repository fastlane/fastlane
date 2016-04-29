require 'ostruct'
describe Frameit do
  describe Frameit::TemplateFinder do
    describe 'it can find some screenshots' do
      # Prevent the tests from looking in the real home
      # directory.
      before(:all) do
        @old_env_home = ENV['HOME']
        ENV['HOME'] = '/thisdirectorydoesnotexist'
      end

      after(:all) do
        ENV['HOME'] = @old_env_home
      end

      def make_screenshot(overrides = {})
        defaults = {
          mac?: false,
          color: 'silver',
          orientation_name: 'Horz'
        }

        OpenStruct.new(defaults.merge(overrides))
      end

      it 'returns nil for mac screenshots' do
        screenshot = make_screenshot({mac?: true})
        expected_result = nil

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds a vertical iphone se' do
        screenshot = make_screenshot({
          device_name: 'iPhone-SE',
          color: 'SpaceGray',
          orientation_name: 'Vert'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPhone SE/iPhone-SE-Space-Gray.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds a horizontal iphone se' do
        screenshot = make_screenshot({
          device_name: 'iPhone-SE',
          color: 'Silver',
          orientation_name: 'Horz'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPhone SE/iPhone-SE-Silver-horizontal.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iphone 5s' do
        screenshot = make_screenshot({
          device_name: 'iPhone_5s',
          color: 'SpaceGray',
          orientation_name: 'Horz'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPhone 5s/Space Gray/iPhone_5s_Horz_SpaceGray_sRGB.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iPhone 6s' do
        screenshot = make_screenshot({
          device_name: 'iPhone-6s'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPhone-6s/iPhone 6s - Silver/iPhone-6s-Silver-horizontal.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iPhone 6s Plus' do
        screenshot = make_screenshot({
          device_name: 'iPhone-6s-Plus',
          orientation_name: 'Horz'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPhone-6s-Plus/iPhone 6s Plus - Silver/iPhone-6s-Plus-Silver-horizontal.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an ipad mini' do
        screenshot = make_screenshot({
          device_name: 'iPad-mini'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPad-mini-4/iPad mini Silver/iPad-mini-Silver-horizontal.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an ipad pro' do
        screenshot = make_screenshot({
          device_name: 'iPad-Pro',
          color: 'SpaceGray',
          orientation_name: 'Vert'
        })
        expected_result = '../frameit/spec/fixtures/mock_frames/iPad Pro/iPad-Pro-Space-Gray-vertical.png'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'warns for an iPhone-SE if there is no template' do
        screenshot = make_screenshot({
          device_name: 'iPhone-SE',
          color: 'SpaceGray',
          orientation_name: 'Vert'
        })

        expect(Dir).to receive(:[]).and_return([]).at_least(:once)
        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(nil)
      end
    end
  end
end
