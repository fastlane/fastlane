require 'plist'

require_relative 'client_stubbing'
require_relative 'connect_api/provisioning/provisioning_stubbing'
require_relative 'connect_api/testflight/testflight_stubbing'
require_relative 'connect_api/tunes/tunes_stubbing'
require_relative 'connect_api/users/users_stubbing'
require_relative 'portal/portal_stubbing'
require_relative 'tunes/tunes_stubbing'
require_relative 'du/du_stubbing'
# Ensure that no ENV vars which interfere with testing are set
#
set_auth_vars = [
  'FASTLANE_SESSION',
  'FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD',
  'FASTLANE_PASSWORD'
].select { |var| ENV.key?(var) }

if set_auth_vars.any?
  abort("[!] Please `unset` the following ENV vars which interfere with spaceship testing: #{set_auth_vars.join(', ')}".red)
end

@cache_paths = [
  File.expand_path("/tmp/spaceship_itc_service_key.txt")
]

def try_delete(path)
  FileUtils.rm_f(path) if File.exist?(path)
end

def before_each_spaceship
  @cache_paths.each { |path| try_delete(path) }
  ENV["DELIVER_USER"] = "spaceship@krausefx.com"
  ENV["DELIVER_PASSWORD"] = "so_secret"
  ENV['SPACESHIP_AVOID_XCODE_API'] = 'true'

  ENV.delete("FASTLANE_USER")

  TunesStubbing.itc_stub_login
  PortalStubbing.adp_stub_login

  PortalStubbing.adp_stub_app_groups
  PortalStubbing.adp_stub_apps

  PortalStubbing.adp_stub_provisioning
  PortalStubbing.adp_stub_certificates
  PortalStubbing.adp_stub_devices
  PortalStubbing.adp_stub_persons
  PortalStubbing.adp_stub_website_pushes
  PortalStubbing.adp_stub_passbooks
  TunesStubbing.itc_stub_applications
  TunesStubbing.itc_stub_app_versions
  TunesStubbing.itc_stub_build_trains
  TunesStubbing.itc_stub_testers
  TunesStubbing.itc_stub_testflight
  TunesStubbing.itc_stub_app_version_ref
  TunesStubbing.itc_stub_user_detail
  TunesStubbing.itc_stub_sandbox_testers
  TunesStubbing.itc_stub_create_sandbox_tester
  TunesStubbing.itc_stub_delete_sandbox_tester
  TunesStubbing.itc_stub_candidate_builds
  TunesStubbing.itc_stub_pricing_tiers
  TunesStubbing.itc_stub_release_to_store
  TunesStubbing.itc_stub_release_to_all_users
  TunesStubbing.itc_stub_promocodes
  TunesStubbing.itc_stub_generate_promocodes
  TunesStubbing.itc_stub_promocodes_history
  TunesStubbing.itc_stub_supported_countries

  ConnectAPIStubbing::Provisioning.stub_available_bundle_id_capabilities
  ConnectAPIStubbing::Provisioning.stub_bundle_ids
  ConnectAPIStubbing::Provisioning.stub_bundle_id
  ConnectAPIStubbing::Provisioning.stub_patch_bundle_id_capability
  ConnectAPIStubbing::Provisioning.stub_certificates
  ConnectAPIStubbing::Provisioning.stub_devices
  ConnectAPIStubbing::Provisioning.stub_profiles

  ConnectAPIStubbing::TestFlight.stub_apps
  ConnectAPIStubbing::TestFlight.stub_beta_app_localizations
  ConnectAPIStubbing::TestFlight.stub_beta_app_review_details
  ConnectAPIStubbing::TestFlight.stub_beta_app_review_submissions
  ConnectAPIStubbing::TestFlight.stub_beta_build_localizations
  ConnectAPIStubbing::TestFlight.stub_beta_build_metrics
  ConnectAPIStubbing::TestFlight.stub_beta_feedbacks
  ConnectAPIStubbing::TestFlight.stub_beta_feedbacks_delete
  ConnectAPIStubbing::TestFlight.stub_beta_groups
  ConnectAPIStubbing::TestFlight.stub_beta_testers
  ConnectAPIStubbing::TestFlight.stub_beta_tester_metrics
  ConnectAPIStubbing::TestFlight.stub_build_beta_details
  ConnectAPIStubbing::TestFlight.stub_build_bundles
  ConnectAPIStubbing::TestFlight.stub_build_deliveries
  ConnectAPIStubbing::TestFlight.stub_builds
  ConnectAPIStubbing::TestFlight.stub_pre_release_versions

  ConnectAPIStubbing::Tunes.stub_app_store_version_release_request

  ConnectAPIStubbing::Users.stub_users
end

def after_each_spaceship
  @cache_paths.each { |path| try_delete(path) }
end

RSpec.configure do |config|
  def mock_client_response(method_name, with: anything)
    mock_method = allow(mock_client).to receive(method_name)
    mock_method = mock_method.with(with)
    if block_given?
      mock_method.and_return(JSON.parse(yield.to_json))
    else
      mock_method
    end
  end
end

RSpec.shared_examples("common spaceship login") do |skip_tunes_login|
  require 'fastlane-sirp'
  let(:authentication_data) {
    '8f30ce83b660f03abb0f8570c235e0e1e1d3860a222304acf18e989bdc065dc922a141e6da4563f0' \
      '5586605b0e10535d875ca7e0fae7fe100cfe533374f29aaa803cdfb2c6194f458485e87f76988f6' \
      'cddaa1829309438e1aa9ab652b17cfc081fff40356cb3af35c621e9f37ba6e2a03e6abac5a6bfe' \
      '18ddb489412b7c56355292e6c355f8859270d04063b843d23c1ef7503c3c5dd2c56740101a3ef5' \
      'bfec6bff1e6dc55e3f70840a83a95d7b3d20ab350d0472809ce87a4e3c29ed9685eb7721dc87ba' \
      'bfadbd9e65e75d5df55547bcff98711ddeae7b8e1e6dbf529e96f7caa4b830b43575cddc52cebc' \
      '39f9522f85cbf33ac35ee59f66f48109c12fbb78d'
  }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before {
    allow_any_instance_of(SIRP::Client).to receive(:start_authentication).and_return(authentication_data)
    allow_any_instance_of(SIRP::Client).to receive(:process_challenge).and_return("1234")

    Spaceship::Tunes.login unless skip_tunes_login
  }
end
