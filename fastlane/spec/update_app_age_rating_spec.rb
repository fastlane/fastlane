# frozen_string_literal: true

require 'deliver'
require_relative '../lib/fastlane/actions/update_app_age_rating'

describe Fastlane::Actions::UpdateAppAgeRatingAction do
  let(:app_id)      { 'com.example.app' }
  let(:config_path) { '/tmp/age_rating.json' }
  let(:app)         { double('Spaceship::ConnectAPI::App') }
  let(:app_info)    { double('Spaceship::ConnectAPI::AppInfo') }
  let(:age_rating)  { double('Spaceship::ConnectAPI::AgeRatingDeclaration') }
  let(:valid_json)  { '{"VIOLENCE":"FREQUENT"}' }
  let(:mapped_key)  { 'violence_cartoon_fantasy' }
  let(:mapped_val)  { 2 }

  # Shared setup: establishes the full happy-path stub set.
  # Individual contexts override only the piece they are exercising.
  before do
    allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(nil)
    allow(Spaceship::ConnectAPI).to receive(:login)
    allow(Spaceship::ConnectAPI).to receive(:token=)

    allow(Spaceship::ConnectAPI::App).to receive(:find).with(app_id).and_return(app)
    allow(app).to receive(:fetch_edit_app_info).and_return(app_info)
    allow(app_info).to receive(:fetch_age_rating_declaration).and_return(age_rating)
    allow(age_rating).to receive(:update)

    allow(File).to receive(:exist?).with(config_path).and_return(true)
    allow(File).to receive(:read).with(config_path).and_return(valid_json)

    allow(Spaceship::ConnectAPI::AgeRatingDeclaration)
      .to receive(:map_key_from_itc).with('VIOLENCE').and_return(mapped_key)
    allow(Spaceship::ConnectAPI::AgeRatingDeclaration)
      .to receive(:map_value_from_itc).with(mapped_key, 'FREQUENT').and_return(mapped_val)
  end

  # Convenience: avoids repeating the full params hash in every example
  def run(overrides = {})
    described_class.run({
      app_identifier: app_id,
      age_rating_config_path: config_path,
      username: 'user@example.com'
    }.merge(overrides))
  end

  # ---------------------------------------------------------------------------
  describe 'authentication' do
    context 'when an api_key hash is provided' do
      let(:api_key) { { key_id: 'KEY', issuer_id: 'ISSUER', key: 'CONTENT' } }
      let(:token)   { double('Spaceship::ConnectAPI::Token') }

      before do
        allow(Spaceship::ConnectAPI::Token).to receive(:from)
          .with(hash: api_key, filepath: nil).and_return(token)
      end

      it 'sets the Spaceship token and skips Apple ID login' do
        expect(Spaceship::ConnectAPI).to receive(:token=).with(token)
        expect(Spaceship::ConnectAPI).not_to receive(:login)
        run(api_key: api_key)
      end
    end

    context 'when an api_key_path is provided' do
      let(:token) { double('Spaceship::ConnectAPI::Token') }

      before do
        allow(Spaceship::ConnectAPI::Token).to receive(:from)
          .with(hash: nil, filepath: '/tmp/api_key.json').and_return(token)
      end

      it 'sets the Spaceship token and skips Apple ID login' do
        expect(Spaceship::ConnectAPI).to receive(:token=).with(token)
        expect(Spaceship::ConnectAPI).not_to receive(:login)
        run(api_key_path: '/tmp/api_key.json')
      end
    end

    context 'when no API key is provided' do
      before do
        allow(Spaceship::ConnectAPI::Token).to receive(:from)
          .with(hash: nil, filepath: nil).and_return(nil)
      end

      it 'falls back to Apple ID username/password login' do
        expect(Spaceship::ConnectAPI).to receive(:login).with(
          'user@example.com',
          nil,
          use_portal: false,
          use_tunes: true,
          team_id: nil,
          team_name: nil
        )
        run
      end
    end
  end

  # ---------------------------------------------------------------------------
  describe '#run' do
    context 'when all inputs are valid' do
      it 'finds the app by bundle identifier' do
        expect(Spaceship::ConnectAPI::App).to receive(:find).with(app_id).and_return(app)
        run
      end

      it 'fetches the editable app info' do
        expect(app).to receive(:fetch_edit_app_info).and_return(app_info)
        run
      end

      it 'fetches the age rating declaration' do
        expect(app_info).to receive(:fetch_age_rating_declaration).and_return(age_rating)
        run
      end

      it 'updates the declaration with correctly mapped attributes' do
        expect(age_rating).to receive(:update).with(
          attributes: { mapped_key => mapped_val }
        )
        run
      end

      it 'returns true' do
        expect(run).to be(true)
      end
    end

    context 'when the app cannot be found' do
      before { allow(Spaceship::ConnectAPI::App).to receive(:find).and_return(nil) }

      it 'raises a user-facing error' do
        expect { run }.to raise_error(
          FastlaneCore::Interface::FastlaneError,
          /Could not find app with identifier/
        )
      end
    end

    context 'when app info cannot be fetched' do
      before { allow(app).to receive(:fetch_edit_app_info).and_return(nil) }

      it 'raises a user-facing error' do
        expect { run }.to raise_error(
          FastlaneCore::Interface::FastlaneError,
          /Could not fetch editable app info/
        )
      end
    end

    context 'when the config file contains invalid JSON' do
      before { allow(File).to receive(:read).with(config_path).and_return('{ invalid') }

      it 'raises a user-facing error' do
        expect { run }.to raise_error(
          FastlaneCore::Interface::FastlaneError,
          /Invalid JSON in age rating configuration file/
        )
      end
    end

    context 'when the age rating declaration cannot be fetched' do
      before { allow(app_info).to receive(:fetch_age_rating_declaration).and_return(nil) }

      it 'raises a user-facing error' do
        expect { run }.to raise_error(
          FastlaneCore::Interface::FastlaneError,
          /Could not fetch age rating declaration/
        )
      end
    end
  end

  # ---------------------------------------------------------------------------
  describe '.available_options' do
    subject(:options) { described_class.available_options }

    it 'returns an array of FastlaneCore::ConfigItem objects' do
      expect(options).to all(be_a(FastlaneCore::ConfigItem))
    end

    it 'marks :app_identifier and :age_rating_config_path as required' do
      required_keys = options.reject(&:optional).map(&:key)
      expect(required_keys).to include(:app_identifier, :age_rating_config_path)
    end

    it 'marks auth and team options as optional' do
      optional_keys = options.select(&:optional).map(&:key)
      expect(optional_keys).to include(:api_key, :api_key_path, :username, :team_id, :team_name)
    end

    it 'marks :api_key and :api_key_path as conflicting options with each other' do
      api_key_item = options.find { |o| o.key == :api_key }
      expect(api_key_item.conflicting_options).to include(:api_key_path)
    end
  end

  # ---------------------------------------------------------------------------
  describe '.is_supported?' do
    it 'returns true for :ios'      do expect(described_class.is_supported?(:ios)).to   be(true)  end
    it 'returns true for :mac'      do expect(described_class.is_supported?(:mac)).to   be(true)  end
    it 'returns true for :tvos'     do expect(described_class.is_supported?(:tvos)).to  be(true)  end
    it 'returns false for :android' do expect(described_class.is_supported?(:android)).to be(false) end
  end

  # ---------------------------------------------------------------------------
  describe '.description' do
    it 'returns a non-empty string' do
      expect(described_class.description).not_to be_empty
    end
  end

  # ---------------------------------------------------------------------------
  describe '.authors' do
    it 'includes the contributor handle' do
      expect(described_class.authors).to include('PratikPatil131')
    end
  end
end
