require 'spec_helper'

describe Spaceship do
  before { Spaceship.login }

  it 'should initialize with a client' do
    expect(Spaceship.client).to be_instance_of(Spaceship::Client)
  end
end
