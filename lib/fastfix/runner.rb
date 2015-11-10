module Fastfix
  class Runner
    def run(params)
      cert_type = :distribution
      cert_type = :development if params[:type] == :development

      prov_type = params[:type]

      params[:path] = GitHelper.clone(params[:git_url]) if params[:git_url]

      certs = Dir[File.join(params[:path], "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:path], "**", cert_type.to_s, "*.p12")]

      profile_name = [prov_type.to_s, params[:app_identifier]].join("_").gsub("*", '\*') # this is important, as it shouldn't be a wildcard
      profiles = Dir[File.join(params[:path], "**", prov_type.to_s, "#{profile_name}.mobileprovision")]

      certs.each do |cert|
        if FastlaneCore::CertChecker.installed?(cert)
          Helper.log.info "Certificate '#{cert}' is already installed on this machine"
        else
          Utils.import(params, cert)
        end
      end

      # Import all the private keys
      keys.each do |key|
        Utils.import(params, key)
      end

      if certs.count == 0 or keys.count == 0
        Helper.log.error "Couldn't find a valid code signing identity in the git repo..."
        Generator.generate_certificate(params, cert_type)
      end

      # Install the provisioning profiles
      uuid = nil
      profiles.each do |profile|
        parsed = FastlaneCore::ProvisioningProfile.parse(profile)

        FastlaneCore::ProvisioningProfile.install(profile)
        uuid = parsed["UUID"]
        Utils.fill_environment(params, uuid)
      end

      unless uuid
        uuid = Generator.generate_provisioning_profile(params, prov_type)
        Utils.fill_environment(params, uuid)

        # We have to remove the provisioning profile path from the lane context
        # as the temporary folder gets deleted
        Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] = nil
        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = nil
      end

      if params[:git_url]
        message = GitHelper.generate_commit_message(params)
        GitHelper.commit_changes(params[:path], message)
      end

      TablePrinter.print_summary(params, uuid)

      Helper.log.info "All required keys, certificates and provisioning profiles are installed 🙌".green
    end
  end
end
