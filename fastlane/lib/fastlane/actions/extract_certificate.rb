require 'plist'
require 'open3'
require 'openssl'

module Fastlane
  module Actions
    class ExtractCertificateAction < Action
      PROVISIONS = "#{Dir.home}/Library/MobileDevice/Provisioning\ Profiles/".freeze

      # @return [OpenSSL::X509::Certificate]
      def self.run(params)
        path = params[:provision_path]
        path = default_path(params[:uuid]) if path.nil?
        check_profile(path)

        o, e, s = Open3.capture3("security cms -D -i '#{path}'")
        if s.exitstatus != 0
          UI.user_error!("Can't extract plist from provision profile\n" + e)
        end

        provision_plist_raw = o
        provision_plist = Plist.parse_xml(provision_plist_raw)

        cert_data = provision_plist['DeveloperCertificates'][0].string
        cert = OpenSSL::X509::Certificate.new(cert_data)

        print cert.to_text if params[:log_certificate]
        cert
      end

      def self.description
        'Extract certificate public key from provision profile'
      end

      def self.details
        'You can use it to get info about signing certificate' \
          'like certificate name and id'
      end

      def self.check_profile(file)
        UI.user_error!('Empty input') if file.nil?
        UI.user_error!("#{file} does not exist") unless File.exist? file
        UI.user_error!("#{file} is not a file") unless File.file? file
      end

      def self.default_path(uuid)
        File.join PROVISIONS, "#{uuid}.mobileprovision"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(
                key: :provision_path,
                env_name: 'FL_EXTRACT_CERTIFICATE_PR_PATH',
                description: 'Path to provision profile',
                is_string: true,
                optional: true,
                verify_block: proc do |path|
                  check_profile(path)
                end
            ),

            FastlaneCore::ConfigItem.new(
                key: :uuid,
                env_name: 'FL_EXTRACT_CERTIFICATE_UUID',
                description: 'UUID of provision profile in default dir',
                is_string: true,
                optional: true,
                verify_block: proc do |uuid|
                  provision_path = default_path(uuid)
                  check_profile(provision_path)
                end
            ),

            FastlaneCore::ConfigItem.new(
                key: :log_certificate,
                env_name: 'FL_EXTRACT_CERTIFICATE_LOG',
                description: 'Logging extracting certificate',
                optional: true,
                default_value: true,
                is_string: false
            )
        ]
      end


      def self.return_value
        'Returns OpenSSL::X509::Certificate object representing' \
          'signing certificate from provision profile'\
      end

      def self.authors
        ['punksta']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
        OpenSSL::X509::Certificate
      end

      # returns hash object from OpenSSL::X509::Name
      # can be used to get data from subject
      def self.name_to_hash(subject)
        info = subject.to_a.map { |pair| Hash[pair[0], pair[1]] }
        info.inject { |a, e| a.merge(e) { |*hash| hash[1, 2] } }
      end
    end
  end
end
