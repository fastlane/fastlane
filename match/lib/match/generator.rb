require_relative 'module'

module Match
  # Generate missing resources
  class Generator
    def self.generate_certificate(params, cert_type, working_directory)
      require 'cert/runner'
      require 'cert/options'

      output_path = File.join(working_directory, "certs", cert_type.to_s)

      arguments = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: params[:type] == "development",
        output_path: output_path,
        force: true, # we don't need a certificate without its private key, we only care about a new certificate
        username: params[:username],
        team_id: params[:team_id],
        team_name: params[:team_name],
        keychain_path: FastlaneCore::Helper.keychain_path(params[:keychain_name]),
        keychain_password: params[:keychain_password]
      })

      Cert.config = arguments

      begin
        cert_path = Cert::Runner.new.launch
      rescue => ex
        if ex.to_s.include?("You already have a current")
          UI.user_error!("Could not create a new certificate as you reached the maximum number of certificates for this account. You can use the `fastlane match nuke` command to revoke your existing certificates. More information https://docs.fastlane.tools/actions/match/")
        else
          raise ex
        end
      end

      # We don't care about the signing request
      Dir[File.join(working_directory, "**", "*.certSigningRequest")].each { |path| File.delete(path) }

      # we need to return the path
      # Inside this directory, there is the `.p12` file and the `.cer` file with the same name, but different extension
      return cert_path
    end

    # @return (String) The UUID of the newly generated profile
    def self.generate_provisioning_profile(params: nil, prov_type: nil, certificate_id: nil, app_identifier: nil, working_directory: nil)
      require 'sigh/manager'
      require 'sigh/options'

      prov_type = Match.profile_type_sym(params[:type])

      names = ["match", profile_type_name(prov_type), app_identifier]

      if params[:platform].to_s != :ios.to_s # For ios we do not include the platform for backwards compatibility
        names << params[:platform]
      end

      profile_name = names.join(" ")

      values = {
        app_identifier: app_identifier,
        output_path: File.join(working_directory, "profiles", prov_type.to_s),
        username: params[:username],
        force: true,
        cert_id: certificate_id,
        provisioning_name: profile_name,
        ignore_profiles_with_different_name: true,
        team_id: params[:team_id],
        team_name: params[:team_name],
        template_name: params[:template_name]
      }

      values[:platform] = params[:platform]
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
      return "Unknown"
    end
  end
end
