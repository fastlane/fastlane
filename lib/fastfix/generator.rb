module Fastfix
  # Generate missing resources
  class Generator
    def self.generate_certificate(params, cert_type)
      require 'cert'

      arguments = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: params[:type] == :development,
        output_path: File.join(params[:path], "certs", cert_type.to_s),
        force: true, # we don't need a certificate without its private key
        username: params[:username]
      })

      Cert.config = arguments
      Cert::Runner.new.launch

      # We don't care about the signing request
      Dir[File.join(params[:path], "**", "*.certSigningRequest")].each { |path| File.delete(path) }
    end

    # @return (String) The UUID of the newly generated profile
    def self.generate_provisioning_profile(params, prov_type)
      require 'sigh'

      prov_type = :enterprise if ENV["SIGH_PROFILE_ENTERPRISE"]

      arguments = FastlaneCore::Configuration.create(Sigh::Options.available_options, {
        app_identifier: params[:app_identifier],
        adhoc: params[:type] == :adhoc,
        development: params[:type] == :development,
        output_path: File.join(params[:path], "profiles", prov_type.to_s),
        username: params[:username]
      })

      Sigh.config = arguments
      path = Sigh::Manager.start
      parsed = FastlaneCore::ProvisioningProfile.parse(path)
      return parsed["UUID"]
    end
  end
end
