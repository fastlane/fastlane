require 'ostruct'
describe Frameit do
  describe Frameit::TemplateFinder do
    describe 'it can find some screenshots' do
      # Prevent the tests from looking in the real home
      # directory.
      before(:all) do
        @old_env_home = ENV['HOME']
        ENV['HOME'] = '/tmp/thisdirectorydoesnotexist'
      end

      after(:all) do
        ENV['HOME'] = @old_env_home
      end

      def make_screenshot(overrides = {})
        defaults = {
            mac?: false,
            color: 'silver',
            orientation_name: 'Horz',
            deliver_screen_id: 'deliver-id'
        }

        OpenStruct.new(defaults.merge(overrides))
      end

      it 'returns nil for mac screenshots' do
        screenshot = make_screenshot({ mac?: true })
        expected_result = nil

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds a vertical iphone se' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPhone-SE',
                                         color: 'SpaceGray',
                                         orientation_name: 'Vert',
                                         deliver_screen_id: 'iOS-4-in'
        })
        expected_result = 'Apple iPhone-SE SpaceGray'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds a horizontal iphone se' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPhone-SE',
                                         color: 'Silver',
                                         orientation_name: 'Horz',
                                         deliver_screen_id: 'iOS-4-in'
        })
        expected_result = 'Apple iPhone-SE Silver'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iphone 5s' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPhone_5s',
                                         color: 'SpaceGray',
                                         orientation_name: 'Horz',
                                         deliver_screen_id: 'iOS-4-in'
        })
        expected_result = 'Apple iPhone_5s SpaceGray'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iPhone 6s' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPhone-6s',
                                         deliver_screen_id: 'iOS-4.7-in'
        })
        expected_result = 'Apple iPhone-6s silver'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an iPhone 6s Plus' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPhone-6s-Plus',
                                         orientation_name: 'Horz',
                                         deliver_screen_id: 'iOS-4.7-in'
        })
        expected_result = 'Apple iPhone-6s-Plus silver'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an ipad mini' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPad-mini',
                                         deliver_screen_id: 'iOS-iPad'
        })
        expected_result = 'Apple iPad-mini silver'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end

      it 'finds an ipad pro' do
        screenshot = make_screenshot({
                                         device_name: 'Apple iPad-Pro',
                                         color: 'SpaceGray',
                                         orientation_name: 'Vert',
                                         deliver_screen_id: 'iOS-iPad-Pro'
        })
        expected_result = 'Apple iPad-Pro SpaceGray'

        expect(Frameit::TemplateFinder.get_template(screenshot)).to eq(expected_result)
      end
    end
  end
end
