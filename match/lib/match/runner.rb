require 'fastlane_core/cert_checker'
require 'fastlane_core/provisioning_profile'
require 'fastlane_core/print_table'
require 'spaceship/client'
require_relative 'generator'
require_relative 'git_helper'
require_relative 'module'
require_relative 'table_printer'
require_relative 'spaceship_ensure'
require_relative 'utils'

module Match
  class Runner
    attr_accessor :files_to_commmit
    attr_accessor :spaceship

    def run(params)
      self.files_to_commmit = []

      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:workspace],
                                             title: "Summary for match #{Fastlane::VERSION}")

      params[:workspace] = GitHelper.clone(params[:git_url],
                                           params[:shallow_clone],
                                           skip_docs: params[:skip_docs],
                                           branch: params[:git_branch],
                                           git_full_name: params[:git_full_name],
                                           git_user_email: params[:git_user_email],
                                           clone_branch_directly: params[:clone_branch_directly])

      unless params[:readonly]
        self.spaceship = SpaceshipEnsure.new(params[:username], params[:team_id], params[:team_name])
        if params[:type] == "enterprise" && !Spaceship.client.in_house?
          UI.user_error!("You defined the profile type 'enterprise', but your Apple account doesn't support In-House profiles")
        end
      end

      if params[:app_identifier].kind_of?(Array)
        app_identifiers = params[:app_identifier]
      else
        app_identifiers = params[:app_identifier].to_s.split(/\s*,\s*/).uniq
      end

      # sometimes we get an array with arrays, this is a bug. To unblock people using match, I suggest we flatten!
      # then in the future address the root cause of https://github.com/fastlane/fastlane/issues/11324
      app_identifiers.flatten!

      # Verify the App ID (as we don't want 'match' to fail at a later point)
      if spaceship
        app_identifiers.each do |app_identifier|
          spaceship.bundle_identifier_exists(username: params[:username], app_identifier: app_identifier)
        end
      end

      # Certificate
      cert_id = fetch_certificate(params: params)
      spaceship.certificate_exists(username: params[:username], certificate_id: cert_id) if spaceship

      # Provisioning Profiles
      app_identifiers.each do |app_identifier|
        loop do
          break if fetch_provisioning_profile(params: params,
                                      certificate_id: cert_id,
                                      app_identifier: app_identifier)
        end
      end

      # Done
      if self.files_to_commmit.count > 0 && !params[:readonly]
        message = GitHelper.generate_commit_message(params)
        GitHelper.commit_changes(params[:workspace], message, params[:git_url], params[:git_branch], self.files_to_commmit)
      end

      # Print a summary table for each app_identifier
      app_identifiers.each do |app_identifier|
        TablePrinter.print_summary(app_identifier: app_identifier, type: params[:type], platform: params[:platform])
      end

      UI.success("All required keys, certificates and provisioning profiles are installed 🙌".green)
    rescue Spaceship::Client::UnexpectedResponse, Spaceship::Client::InvalidUserCredentialsError, Spaceship::Client::NoUserCredentialsError => ex
      UI.error("An error occurred while verifying your certificates and profiles with the Apple Developer Portal.")
      UI.error("If you already have your certificates stored in git, you can run `fastlane match` in readonly mode")
      UI.error("to just install the certificates and profiles without accessing the Dev Portal.")
      UI.error("To do so, just pass `readonly: true` to your match call.")
      raise ex
    ensure
      GitHelper.clear_changes
    end

    def fetch_certificate(params: nil)
      cert_type = Match.cert_type_sym(params[:type])

      certs = Dir[File.join(params[:workspace], "certs", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:workspace], "certs", cert_type.to_s, "*.p12")]

      if certs.count == 0 || keys.count == 0
        UI.important("Couldn't find a valid code signing identity in the git repo for #{cert_type}... creating one for you now")
        UI.crash!("No code signing identity found and can not create a new one because you enabled `readonly`") if params[:readonly]
        cert_path = Generator.generate_certificate(params, cert_type)
        private_key_path = cert_path.gsub(".cer", ".p12")

        self.files_to_commmit << cert_path
        self.files_to_commmit << private_key_path
      else
        cert_path = certs.last
        UI.message("Installing certificate...")

        # Only looking for cert in "custom" (non login.keychain) keychain
        # Doing this for backwards compatability
        keychain_name = params[:keychain_name] == "login.keychain" ? nil : params[:keychain_name]

        if FastlaneCore::CertChecker.installed?(cert_path, in_keychain: keychain_name)
          UI.verbose("Certificate '#{File.basename(cert_path)}' is already installed on this machine")
        else
          Utils.import(cert_path, params[:keychain_name], password: params[:keychain_password])
        end

        # Import the private key
        # there seems to be no good way to check if it's already installed - so just install it
        Utils.import(keys.last, params[:keychain_name], password: params[:keychain_password])

        # Get and print info of certificate
        info = Utils.get_cert_info(cert_path)
        TablePrinter.print_certificate_info(cert_info: info)
      end

      return File.basename(cert_path).gsub(".cer", "") # Certificate ID
    end

    # @return [String] The UUID of the provisioning profile so we can verify it with the Apple Developer Portal
    def fetch_provisioning_profile(params: nil, certificate_id: nil, app_identifier: nil)
      prov_type = Match.profile_type_sym(params[:type])

      names = [Match::Generator.profile_type_name(prov_type), app_identifier]
      if params[:platform].to_s != :ios.to_s
        names.push(params[:platform])
      end
      profile_name = names.join("_").gsub("*", '\*') # this is important, as it shouldn't be a wildcard
      base_dir = File.join(params[:workspace], "profiles", prov_type.to_s)
      profiles = Dir[File.join(base_dir, "#{profile_name}.mobileprovision")]
      keychain_path = FastlaneCore::Helper.keychain_path(params[:keychain_name]) unless params[:keychain_name].nil?

      # Install the provisioning profiles
      profile = profiles.last

      if params[:force_for_new_devices] && !params[:readonly]
        if prov_type != :appstore
          params[:force] = device_count_different?(profile: profile, keychain_path: keychain_path) unless params[:force]
        else
          # App Store provisioning profiles don't contain device identifiers and
          # thus shouldn't be renewed if the device count has changed.
          UI.important("Warning: `force_for_new_devices` is set but is ignored for App Store provisioning profiles.")
          UI.important("You can safely stop specifying `force_for_new_devices` when running Match for type 'appstore'.")
        end
      end

      if profile.nil? || params[:force]
        if params[:readonly]
          all_profiles = Dir.entries(base_dir).reject { |f| f.start_with?(".") }
          UI.error("No matching provisioning profiles found for '#{profile_name}'")
          UI.error("A new one cannot be created because you enabled `readonly`")
          UI.error("Provisioning profiles in your repo for type `#{prov_type}`:")
          all_profiles.each { |p| UI.error("- '#{p}'") }
          UI.error("If you are certain that a profile should exist, double-check the recent changes to your match repository")
          UI.user_error!("No matching provisioning profiles found and can not create a new one because you enabled `readonly`. Check the output above for more information.")
        end
        profile = Generator.generate_provisioning_profile(params: params,
                                                       prov_type: prov_type,
                                                  certificate_id: certificate_id,
                                                  app_identifier: app_identifier)
        self.files_to_commmit << profile
      end

      installed_profile = FastlaneCore::ProvisioningProfile.install(profile, keychain_path)
      parsed = FastlaneCore::ProvisioningProfile.parse(profile, keychain_path)
      uuid = parsed["UUID"]

      if spaceship && !spaceship.profile_exists(username: params[:username], uuid: uuid)
        # This profile is invalid, let's remove the local file and generate a new one
        File.delete(profile)
        # This method will be called again, no need to modify `files_to_commmit`
        return nil
      end

      Utils.fill_environment(Utils.environment_variable_name(app_identifier: app_identifier,
                                                                       type: prov_type,
                                                                   platform: params[:platform]),

                             uuid)

      # TeamIdentifier is returned as an array, but we're not sure why there could be more than one
      Utils.fill_environment(Utils.environment_variable_name_team_id(app_identifier: app_identifier,
                                                                               type: prov_type,
                                                                           platform: params[:platform]),
                             parsed["TeamIdentifier"].first)

      Utils.fill_environment(Utils.environment_variable_name_profile_name(app_identifier: app_identifier,
                                                                                    type: prov_type,
                                                                                platform: params[:platform]),
                             parsed["Name"])

      Utils.fill_environment(Utils.environment_variable_name_profile_path(app_identifier: app_identifier,
                                                                                    type: prov_type,
                                                                                platform: params[:platform]),
                             installed_profile)

      return uuid
    end

    def device_count_different?(profile: nil, keychain_path: nil)
      if profile
        parsed = FastlaneCore::ProvisioningProfile.parse(profile, keychain_path)
        uuid = parsed["UUID"]
        portal_profile = Spaceship.provisioning_profile.all.detect { |i| i.uuid == uuid }

        if portal_profile
          profile_device_count = portal_profile.devices.count
          portal_device_count = Spaceship.device.all.count
          return portal_device_count != profile_device_count
        end
      end
      return false
    end
  end
end
