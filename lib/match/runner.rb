module Match
  class Runner
    # rubocop:disable Metrics/AbcSize
    def run(params)
      changes_to_commit = false
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:path],
                                             title: "Summary for match #{Match::VERSION}")

      cert_type = :distribution
      cert_type = :development if params[:type] == "development"

      prov_type = params[:type].to_sym

      params[:path] = GitHelper.clone(params[:git_url])

      certs = Dir[File.join(params[:path], "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:path], "**", cert_type.to_s, "*.p12")]

      profile_name = [prov_type.to_s, params[:app_identifier]].join("_").gsub("*", '\*') # this is important, as it shouldn't be a wildcard
      profiles = Dir[File.join(params[:path], "**", prov_type.to_s, "#{profile_name}.mobileprovision")]

      if certs.count == 0 or keys.count == 0
        Helper.log.info "Couldn't find a valid code signing identity in the git repo for #{cert_type}... creating one for you now"
        cert_path = Generator.generate_certificate(params, cert_type)
        changes_to_commit = true
      else
        cert_path = certs.last
        Helper.log.info "Installing certificate..."

        if FastlaneCore::CertChecker.installed?(cert_path)
          Helper.log.info "Certificate '#{File.basename(cert_path)}' is already installed on this machine" if $verbose
        else
          Utils.import(cert_path, params[:keychain_name])
        end

        # Import the private key
        # there seems to be no good way to check if it's already installed - so just install it
        Utils.import(keys.last, params[:keychain_name])
      end

      # Install the provisioning profiles
      profile = profiles.last
      if profile.nil? or params[:force]
        profile = Generator.generate_provisioning_profile(params, prov_type, cert_path)
        changes_to_commit = true
      end

      FastlaneCore::ProvisioningProfile.install(profile)

      parsed = FastlaneCore::ProvisioningProfile.parse(profile)
      uuid = parsed["UUID"]
      Utils.fill_environment(params, uuid)

      if changes_to_commit
        message = GitHelper.generate_commit_message(params)
        GitHelper.commit_changes(params[:path], message, params[:git_url])
      end

      TablePrinter.print_summary(params, uuid)

      Helper.log.info "All required keys, certificates and provisioning profiles are installed 🙌".green
    end
    # rubocop:enable Metrics/AbcSize
  end
end
