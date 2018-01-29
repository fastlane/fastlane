module Fastlane
  module Actions
    module SharedValues
    end

    class ScpAction < Action
      def self.run(params)
        Actions.verify_gem!('net-scp')
        require "net/scp"
        ret = nil
        Net::SCP.start(params[:host], params[:username], { port: params[:port].to_i, password: params[:password] }) do |scp|
          if params[:upload]
            scp.upload!(params[:upload][:src], params[:upload][:dst], recursive: true)
            UI.message(['[SCP COMMAND]', "Successfully Uploaded", params[:upload][:src], params[:upload][:dst]].join(': '))
          end
          if params[:download]

            t_ret = scp.download!(params[:download][:src], params[:download][:dst], recursive: true)
            UI.message(['[SCP COMMAND]', "Successfully Downloaded", params[:download][:src], params[:download][:dst]].join(': '))
            unless params[:download][:dst]
              ret = t_ret
            end
          end
        end
        ret
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Transfer files via SCP"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "FL_SSH_USERNAME",
                                       description: "Username",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       short_option: "-p",
                                       env_name: "FL_SSH_PASSWORD",
                                       description: "Password",
                                       sensitive: true,
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :host,
                                       short_option: "-H",
                                       env_name: "FL_SSH_HOST",
                                       description: "Hostname",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :port,
                                       short_option: "-P",
                                       env_name: "FL_SSH_PORT",
                                       description: "Port",
                                       optional: true,
                                       default_value: "22",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :upload,
                                       short_option: "-U",
                                       env_name: "FL_SCP_UPLOAD",
                                       description: "Upload",
                                       optional: true,
                                       is_string: false,
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :download,
                                       short_option: "-D",
                                       env_name: "FL_SCP_DOWNLOAD",
                                       description: "Download",
                                       optional: true,
                                       is_string: false,
                                       type: Hash)

        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'scp(
            host: "dev.januschka.com",
            username: "root",
            upload: {
              src: "/root/dir1",
              dst: "/tmp/new_dir"
            }
          )',
          'scp(
            host: "dev.januschka.com",
            username: "root",
            download: {
              src: "/root/dir1",
              dst: "/tmp/new_dir"
            }
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
