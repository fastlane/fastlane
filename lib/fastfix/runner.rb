module Fastfix
  class Runner
    def run(params)
      FastlaneCore::PrintTable.print_values(config: params,
                                             title: "Summary for fastfix #{Fastfix::VERSION}")

      cert_type = :distribution
      cert_type = :development if params[:type] == "development"

      prov_type = params[:type].to_sym

      if params[:git_url]
        params[:path] = GitHelper.clone(params[:git_url])
      else
        Helper.log.info "It is recommended to use a separate Git Repo to store your certificates and profiles. Specify one using the `git_url` option.".yellow
      end

      certs = Dir[File.join(params[:path], "**", cert_type.to_s, "*.cer")]
      keys = Dir[File.join(params[:path], "**", cert_type.to_s, "*.p12")]

      profile_name = [prov_type.to_s, params[:app_identifier]].join("_").gsub("*", '\*') # this is important, as it shouldn't be a wildcard
      profiles = Dir[File.join(params[:path], "**", prov_type.to_s, "#{profile_name}.mobileprovision")]

      if certs.count == 0 or keys.count == 0
        Helper.log.info "Couldn't find a valid code signing identity in the git repo for #{cert_type}... creating one for you now"
        Generator.generate_certificate(params, cert_type)
      else
        cert = certs.last
        if FastlaneCore::CertChecker.installed?(cert)
          Helper.log.info "Certificate '#{cert}' is already installed on this machine"
        else
          Utils.import(params, cert)
        end

        # Import the private key
        Utils.import(params, keys.last)
      end

      # Install the provisioning profiles
      profile = profiles.last
      if profile.nil? or params[:force]
        profile = Generator.generate_provisioning_profile(params, prov_type)
      end

      FastlaneCore::ProvisioningProfile.install(profile)

      parsed = FastlaneCore::ProvisioningProfile.parse(profile)
      uuid = parsed["UUID"]
      Utils.fill_environment(params, uuid)

      if params[:git_url]
        message = GitHelper.generate_commit_message(params)
        GitHelper.commit_changes(params[:path], message)
      end

      TablePrinter.print_summary(params, uuid)

      Helper.log.info "All required keys, certificates and provisioning profiles are installed 🙌".green
    end
  end
end
