module Match
  # Generate missing resources
  class Generator
    def self.generate_certificate(params, cert_type)
      require 'cert'
      output_path = File.join(params[:workspace], "certs", cert_type.to_s)

      arguments = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: params[:type] == "development",
        output_path: output_path,
        force: true, # we don't need a certificate without its private key, we only care about a new certificate
        username: params[:username],
        team_id: params[:team_id]
      })

      Cert.config = arguments

      begin
        cert_path = Cert::Runner.new.launch
      rescue => ex
        if ex.to_s.include?("You already have a current")
          UI.user_error!("Could not create a new certificate as you reached the maximum number of certificates for this account. You can use the `match nuke` command to revoke your existing certificates. More information https://github.com/fastlane/fastlane/tree/master/match")
        else
          raise ex
        end
      end

      # We don't care about the signing request
      Dir[File.join(params[:workspace], "**", "*.certSigningRequest")].each { |path| File.delete(path) }

      # we need to return the path
      return cert_path
    end

    # @return (String) The UUID of the newly generated profile
    def self.generate_provisioning_profile(params: nil, prov_type: nil, certificate_id: nil, app_identifier: nil)
      require 'sigh'

      prov_type = Match.profile_type_sym(params[:type])

      profile_name = ["match", profile_type_name(prov_type), app_identifier].join(" ")

      values = {
        app_identifier: app_identifier,
        output_path: File.join(params[:workspace], "profiles", prov_type.to_s),
        username: params[:username],
        force: true,
        cert_id: certificate_id,
        provisioning_name: profile_name,
        ignore_profiles_with_different_name: true,
        team_id: params[:team_id]
      }

      values[:adhoc] = true if prov_type == :adhoc
      values[:development] = true if prov_type == :development

      arguments = FastlaneCore::Configuration.create(Sigh::Options.available_options, values)

      Sigh.config = arguments
      path = Sigh::Manager.start
      return path
    end

    # @return the name of the provisioning profile type
    def self.profile_type_name(type)
      return "Development" if type == :development
      return "AdHoc" if type == :adhoc
      return "AppStore" if type == :appstore
      return "InHouse" if type == :enterprise
      return "Unkown"
    end
  end
end
