describe Spaceship::Utilities do
  describe '#content_type' do
    it 'recognizes the .jpg extension' do
      expect(Spaceship::Utilities.content_type('blah.jpg')).to eq('image/jpeg')
    end

    it 'recognizes the .jpeg extension' do
      expect(Spaceship::Utilities.content_type('blah.jpeg')).to eq('image/jpeg')
    end

    it 'recognizes the .png extension' do
      expect(Spaceship::Utilities.content_type('blah.png')).to eq('image/png')
    end

    it 'recognizes the .geojson extension' do
      expect(Spaceship::Utilities.content_type('blah.geojson')).to eq('application/json')
    end

    it 'recognizes the .mov extension' do
      expect(Spaceship::Utilities.content_type('blah.mov')).to eq('video/quicktime')
    end

    it 'recognizes the .m4v extension' do
      expect(Spaceship::Utilities.content_type('blah.m4v')).to eq('video/mp4')
    end

    it 'recognizes the .mp4 extension' do
      expect(Spaceship::Utilities.content_type('blah.mp4')).to eq('video/mp4')
    end

    it 'raises an exception for unknown extensions' do
      expect { Spaceship::Utilities.content_type('blah.unknown') }.to raise_error("Unknown content-type for file blah.unknown")
    end
  end
end
