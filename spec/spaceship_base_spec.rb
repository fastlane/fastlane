require 'spec_helper'

describe Spaceship::Base do
  let(:client) { double('Client') }
  before { Spaceship.client = double('Default Client') }

  describe 'Class Methods' do
    it 'will use a default client' do
      expect(Spaceship::Base.client).to eq(Spaceship.client)
    end

    it 'can set a client' do
      Spaceship::Base.client = client
      expect(Spaceship::Base.client).to eq(client)
    end

    it 'can set a client and return itself' do
      expect(Spaceship::Base.set_client(client)).to eq(Spaceship::Base)
    end

    describe 'instantiation from an attribute hash' do
      let(:test_class) do
        Class.new(Spaceship::Base) do
          attr_accessor :some_attr_name
          attr_mapping({
            'someAttributeName' => :some_attr_name
          })
        end
      end

      it 'can create an attribute mapping' do
        inst = test_class.new('someAttributeName' => 'some value')
        expect(inst.some_attr_name).to eq('some value')
      end

      it 'can inherit the attribute mapping' do
        subclass = Class.new(test_class)
        inst = subclass.new('someAttributeName' => 'some value')
        expect(inst.some_attr_name).to eq('some value')
      end
    end

    it 'can constantize subclasses by calling a method on the parent class' do
      class Developer < Spaceship::Base
        class RubyDeveloper < Developer
        end
      end

      expect(Developer.ruby_developer).to eq(Developer::RubyDeveloper)
    end
  end
end
