describe Spaceship::Tunes::DeviceType do
  describe "type identifiers" do
    it "should be checkable using singleton functions" do
      expect(Spaceship::Tunes::DeviceType.exists?("iphone6")).to be_truthy
    end

    it "should return an array of string device types" do
      Spaceship::Tunes::DeviceType.types.each do |identifier|
        expect(identifier).to be_a(String)
      end
    end

    it "should contain all old identifiers" do
      old_types = [
        # iPhone
        'iphone35',
        'iphone4',
        'iphone6', # 4.7-inch Display
        'iphone6Plus', # 5.5-inch Display
        'iphone58', # iPhone XS
        'iphone65', # iPhone XS Max

        # iPad
        'ipad', # 9.7-inch Display
        'ipad105',
        'ipadPro',
        'ipadPro11',
        'ipadPro129',

        # Apple Watch
        'watch', # series 3
        'watchSeries4',

        # Apple TV
        'appleTV',

        # Mac
        'desktop'
      ]

      old_types.each do |identifier|
        expect(Spaceship::Tunes::DeviceType.types).to include(identifier)
      end
    end
  end
end
