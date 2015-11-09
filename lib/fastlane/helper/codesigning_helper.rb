module Fastlane
  module Helper
    class CodesigningHelper
      #####################################################
      # @!group General
      #####################################################

      def self.import(params, item_path)
        command = "security import #{item_path.shellescape} -k ~/Library/Keychains/#{params[:keychain_name].shellescape}"
        command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
        command << " -T /usr/bin/security"
        begin
          Fastlane::Actions.sh(command, log: false)
        rescue => ex
          if ex.to_s.include?("SecKeychainItemImport: The specified item already exists in the keychain")
            return true
          else
            raise ex
          end
        end
        true
      end

      #####################################################
      # @!group Generate missing resources
      #####################################################
      def self.generate_certificate(params, cert_type)
        arguments = ConfigurationHelper.parse(Actions::CertAction, {
          development: params[:type] == :development,
          output_path: File.join(params[:path], "certs", cert_type.to_s),
          force: true # we don't need a certificate without its private key
        })

        Actions::CertAction.run(arguments)
        # We don't care about the signing request
        Dir[File.join(params[:path], "**", "*.certSigningRequest")].each { |path| File.delete(path) }
      end

      def self.generate_provisioning_profile(params, prov_type)
        prov_type = :enterprise if ENV["SIGH_PROFILE_ENTERPRISE"]

        arguments = ConfigurationHelper.parse(Actions::SighAction, {
          app_identifier: params[:app_identifier],
          adhoc: params[:type] == :adhoc,
          development: params[:type] == :development,
          output_path: File.join(params[:path], "profiles", prov_type.to_s)
        })

        Actions::SighAction.run(arguments)
      end

      #####################################################
      # @!group Git Actions
      #####################################################
      def self.clone(git_url)
        dir = Dir.mktmpdir
        command = "git clone '#{git_url}' '#{dir}' --depth 1"
        Helper.log.info "Cloning remote git repo..."
        Actions.sh(command)

        return dir
      end

      def self.commit_changes(path)
        Dir.chdir(path) do
          return if `git status`.include?("nothing to commit")
          commands = []
          commands << "git add -A"
          commands << "git commit -m 'Automatic commit via fastlane'"
          commands << "git push origin master"

          commands.each do |command|
            Action.sh(command)
          end
        end

        FileUtils.rm_rf(path)
      end
    end
  end
end
