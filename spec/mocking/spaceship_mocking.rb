require 'spaceship'

def stub_spaceship
  allow(Spaceship::Tunes).to receive(:login).and_return(nil)
end
