RSpec::Matchers.define(:a_configuration_matching) do |expected|
  match do |actual|
    actual.values == expected.values
  end
end

def before_each_match
  ENV["DELIVER_USER"] = "flapple@krausefx.com"
  ENV["DELIVER_PASSWORD"] = "so_secret"
end

def create_fake_storage(match_config:, repo_dir:)
  fake_storage = "fake_storage"
  expect(Match::Storage::GitStorage).to receive(:configure).with({
    git_url: match_config[:git_url] || default_git_url,
    shallow_clone: match_config[:shallow_clone] || false,
    skip_docs: match_config[:skip_docs] || false,
    git_branch: match_config[:git_branch] || "master",
    git_full_name: nil,
    git_user_email: nil,
    clone_branch_directly: match_config[:clone_branch_directly] || false,
    git_basic_authorization: nil,
    git_bearer_authorization: nil,
    git_private_key: nil,
    type: match_config[:type],
    platform: match_config[:platform]
  }).and_return(fake_storage)

  allow(fake_storage).to receive(:git_url).and_return(match_config[:git_url])
  allow(fake_storage).to receive(:working_directory).and_return(repo_dir)
  allow(fake_storage).to receive(:prefixed_working_directory).and_return(repo_dir)

  # Ensure match downloads storage.
  expect(fake_storage).to receive(:download).and_return(nil)
  # Ensure match clears changes after completion.
  expect(fake_storage).to receive(:clear_changes).and_return(nil)

  return fake_storage
end

def default_app_identifier
  "tools.fastlane.app"
end

def default_provisioning_type
  "appstore"
end

def default_git_url
  "https://github.com/fastlane/fastlane/tree/master/certificates"
end

def default_username
  "flapple@something.com"
end

def create_match_config_with_git_storage(extra_values: {}, git_url: nil, app_identifier: nil, type: nil, username: nil)
  values = {
    app_identifier: app_identifier || default_app_identifier,
    type: type || default_provisioning_type,
    git_url: git_url || default_git_url,
    username: username || default_username,
    shallow_clone: true
  }

  extra_values.each do |k, v|
    values[k] = v
  end

  match_config = FastlaneCore::Configuration.create(Match::Options.available_options, values)

  return match_config
end

def create_fake_encryption(storage:)
  fake_encryption = "fake_encryption"
  expect(Match::Encryption::OpenSSL).to receive(:new).with(keychain_name: storage.git_url, working_directory: storage.working_directory).and_return(fake_encryption)

  # Ensure files from storage are decrypted.
  expect(fake_encryption).to receive(:decrypt_files).and_return(nil)

  return fake_encryption
end

def create_fake_spaceship_ensure
  spaceship_ensure = "spaceship"

  allow(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship_ensure)

  # Ensure app identifiers are validated.
  expect(spaceship_ensure).to receive(:bundle_identifier_exists).and_return(true)

  return spaceship_ensure
end

def create_fake_cache(allow_usage: true)
  fake_cache = 'fake_cache'

  allow(Match::Portal::Cache).to receive(:new).and_return(fake_cache)

  if allow_usage
    allow(fake_cache).to receive(:bundle_ids).and_return(nil)
    allow(fake_cache).to receive(:certificates).and_return(nil)
    allow(fake_cache).to receive(:profiles).and_return(nil)
    allow(fake_cache).to receive(:devices).and_return(nil)
    allow(fake_cache).to receive(:portal_profile).and_return(nil)
    allow(fake_cache).to receive(:reset_certificates)
  else
    expect(Match::Portal::Cache).not_to receive(:new)

    expect(fake_cache).not_to receive(:bundle_ids)
    expect(fake_cache).not_to receive(:certificates)
    expect(fake_cache).not_to receive(:profiles)
    expect(fake_cache).not_to receive(:devices)
    expect(fake_cache).not_to receive(:portal_profile)
    expect(fake_cache).not_to receive(:reset_certificates)
  end

  fake_cache
end
