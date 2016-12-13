describe Spaceship::Base do
  let(:client) { double('Client') }
  before { Spaceship::Portal.client = double('Default Client') }

  describe 'Class Methods' do
    it 'will use a default client' do
      expect(Spaceship::PortalBase.client).to eq(Spaceship::Portal.client)
    end

    it 'can set a client' do
      Spaceship::PortalBase.client = client
      expect(Spaceship::PortalBase.client).to eq(client)
    end

    it 'can set a client and return itself' do
      expect(Spaceship::PortalBase.set_client(client)).to eq(Spaceship::PortalBase)
    end

    describe 'instantiation from an attribute hash' do
      let(:test_class) do
        Class.new(Spaceship::PortalBase) do
          attr_accessor :some_attr_name
          attr_accessor :nested_attr_name
          attr_accessor :is_live

          attr_mapping({
            'someAttributeName' => :some_attr_name,
            'nestedAttribute.name.value' => :nested_attr_name,
            'isLiveString' => :is_live
          })

          def is_live
            super == 'true'
          end
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

      it 'can map nested attributes' do
        inst = test_class.new({ 'nestedAttribute' => { 'name' => { 'value' => 'a value' } } })
        expect(inst.nested_attr_name).to eq('a value')
      end

      it 'can overwrite an attribute and call super' do
        inst = test_class.new({ 'isLiveString' => 'true' })
        expect(inst.is_live).to eq(true)
      end
    end

    it 'can constantize subclasses by calling a method on the parent class' do
      class Developer < Spaceship::PortalBase
        class RubyDeveloper < Developer
        end
      end

      expect(Developer.ruby_developer).to eq(Developer::RubyDeveloper)
    end
  end
end
