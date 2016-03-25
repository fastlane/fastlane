module Fastlane
  module Actions
    module SharedValues
      SSH_STDOUT_VALUE = :SSH_STDOUT_VALUE
      SSH_STDERR_VALUE = :SSH_STDERR_VALUE
    end

    class SshAction < Action
      def self.ssh_exec!(ssh, command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
            end
            channel.on_data do |ch1, data|
              stdout_data += data
            end

            channel.on_extended_data do |ch2, type, data|
              stderr_data += data
            end

            channel.on_request("exit-status") do |ch3, data|
              exit_code = data.read_long
            end

            channel.on_request("exit-signal") do |ch4, data|
              exit_signal = data.read_long
            end
          end
        end
        ssh.loop
        {stdout: stdout_data, stderr: stderr_data, exit_code: exit_code, exit_signal: exit_signal}
      end

      def self.run(params)
        Actions.verify_gem!('net-ssh')
        require "net/ssh"

        Actions.lane_context[SharedValues::SSH_STDOUT_VALUE] = ""
        Actions.lane_context[SharedValues::SSH_STDERR_VALUE] = ""
        stdout = ""
        stderr = ""

        Net::SSH.start(params[:host], params[:username], {port: params[:port].to_i, password: params[:password]}) do |ssh|
          params[:commands].each do |cmd|
            UI.important(['[SSH COMMAND]', cmd].join(': ')) if params[:log]
            return_value = ssh_exec!(ssh, cmd)
            UI.error("SSH Command failed '#{cmd}' Exit-Code: #{return_value[:exit_code]}") if return_value[:exit_code] > 0
            UI.user_error!("SSH Command failed") if return_value[:exit_code] > 0

            stderr << return_value[:stderr]
            stdout << return_value[:stdout]
          end
        end
        UI.message("Succesfully executed #{params[:commands].count} commands on host: #{params[:host]}")
        UI.message("\n########### \n #{stdout} \n###############".magenta) if params[:log]
        Actions.lane_context[SharedValues::SSH_STDOUT_VALUE] = stdout
        Actions.lane_context[SharedValues::SSH_STDERR_VALUE] = stderr
        return {stdout: Actions.lane_context[SharedValues::SSH_STDOUT_VALUE], stderr: Actions.lane_context[SharedValues::SSH_STDERR_VALUE]}
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Allows remote command execution using ssh"
      end

      def self.details
        "Lets you execute remote commands via ssh using username/password or ssh-agent"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "FL_SSH_USERNAME",
                                       description: "Username",
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :password,
                                       short_option: "-p",
                                       env_name: "FL_SSH_PASSWORD",
                                       description: "Password",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :host,
                                       short_option: "-H",
                                       env_name: "FL_SSH_HOST",
                                       description: "Hostname",
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :port,
                                       short_option: "-P",
                                       env_name: "FL_SSH_PORT",
                                       description: "Port",
                                       optional: true,
                                       default_value: "22",
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :commands,
                                       short_option: "-C",
                                       env_name: "FL_SSH_COMMANDS",
                                       description: "Commands",
                                       optional: true,
                                       is_string: false,
                                       type: Array
                                      ),
          FastlaneCore::ConfigItem.new(key: :log,
                                       short_option: "-l",
                                       env_name: "FL_SSH_LOG",
                                       description: "Log Commands",
                                       optional: true,
                                       default_value: true,
                                       is_string: false
                                      )
        ]
      end

      def self.output
        [
          ['SSH_STDOUT_VALUE', 'Holds the standard-output of all commands'],
          ['SSH_STDERR_VALUE', 'Holds the standard-error of all commands']
        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
