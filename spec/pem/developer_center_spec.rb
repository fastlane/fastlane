require 'spec_helper'

describe PEM::DeveloperCenter do
  context 'there are some certificates already' do
    before do
      PEM::DeveloperCenter.any_instance.stub(login: true)
      subject.visit URI.join('file:///', fixture_path('push_certs_list.html'))
    end

    it 'read development certs' do
      PEM.config = {
          :development => true
      }

      expect(PEM.config[:development]).to be_truthy
      expect(subject.has_actual_cert).to be_truthy
    end

    it 'read production certs' do
      PEM.config = {}

      expect(PEM.config[:development]).to_not be_truthy
      expect(subject.has_actual_cert).to_not be_truthy
    end
  end

  context 'no development certificates was created' do
    before do
      PEM::DeveloperCenter.any_instance.stub(login: true)
      subject.visit URI.join('file:///', fixture_path('push_certs_list_empty.html'))
    end

    it 'read development certs (no one is there)' do
      PEM.config = {
          :development => true
      }

      expect(subject.has_actual_cert).to_not be_truthy
    end

  end
end