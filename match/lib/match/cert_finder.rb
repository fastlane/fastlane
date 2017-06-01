module Match
  class CertFinder
    def self.find_certificate_ids(params, cert_type)
      require 'cert'
      platform = params[:platform]
      platform = :macos if params[:platform].to_s == 'osx'

      arguments = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: params[:type] == "development",
        distribution_type: params[:distribution_type],
        # output_path: output_path,
        #force: false, # we don't need a certificate without its private key, we only care about a new certificate
        username: params[:username],
        team_id: params[:team_id],
        platform: platform,
        keychain_path: FastlaneCore::Helper.keychain_path(params[:keychain_name])
      })

      Cert.config = arguments

      runner = Cert::Runner.new
      runner.login
      # only return the type of certificates we are interested in
      cert_ids = []
      runner.certificates.each do |certificate|
        next unless certificate.can_download
        next unless certificate.expires > Time.now.utc
        cert_ids << certificate.id
      end
      return cert_ids
    end
  end
end
