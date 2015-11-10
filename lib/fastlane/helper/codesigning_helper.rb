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

      # Fill in the UUID of the profiles in environment variables, much recycling
      def self.fill_environment(params, uuid)
        # instead we specify the UUID of the profiles
        key = environment_variable_name(params)
        Helper.log.info "Setting environment variable '#{key}' to '#{uuid}'".yellow
        ENV[key] = uuid
      end

      def self.print_summary(params, uuid)
        require 'terminal-table'
        rows = []

        rows << ["App Identifier", params[:app_identifier]]
        rows << ["Type", params[:type]]
        rows << ["UUID", uuid]
        rows << ["Environment Variable", environment_variable_name(params)]

        params = {}
        params[:rows] = rows
        params[:title] = "Installed Provisioning Profile".green

        puts ""
        puts Terminal::Table.new(params)
        puts ""
      end

      def self.environment_variable_name(params)
        ["sigh", params[:app_identifier], params[:type]].join("_")
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

      # @return (String) The UUID of the newly generated profile
      def self.generate_provisioning_profile(params, prov_type)
        prov_type = :enterprise if ENV["SIGH_PROFILE_ENTERPRISE"]

        arguments = ConfigurationHelper.parse(Actions::SighAction, {
          app_identifier: params[:app_identifier],
          adhoc: params[:type] == :adhoc,
          development: params[:type] == :development,
          output_path: File.join(params[:path], "profiles", prov_type.to_s)
        })

        Actions::SighAction.run(arguments)

        return Actions.lane_context[Actions::SharedValues::SIGH_UDID]
      end

      #####################################################
      # @!group Git Actions
      #####################################################
      def self.clone(git_url)
        return @dir if @dir

        @dir = Dir.mktmpdir
        command = "git clone '#{git_url}' '#{@dir}' --depth 1"
        Helper.log.info "Cloning remote git repo..."
        Actions.sh(command)

        return @dir
      end

      def self.generate_commit_message(params)
        # 'Automatic commit via fastlane'
        [
          "[fastlane]",
          "Updated",
          params[:app_identifier],
          "for",
          params[:type].to_s
        ].join(" ")
      end

      def self.commit_changes(path, message)
        Dir.chdir(path) do
          return if `git status`.include?("nothing to commit")
          commands = []
          commands << "git add -A"
          commands << "git commit -m '#{message}'"
          commands << "git push origin master"

          commands.each do |command|
            Action.sh(command)
          end
        end
      end
    end
  end
end
