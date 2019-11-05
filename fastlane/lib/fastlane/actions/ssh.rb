module Fastlane
  module Actions
    module SharedValues
      SSH_STDOUT_VALUE = :SSH_STDOUT_VALUE
      SSH_STDERR_VALUE = :SSH_STDERR_VALUE
    end

    class SshAction < Action
      def self.ssh_exec!(ssh, command, log = true)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            unless success
              abort("FAILED: couldn't execute command (ssh.channel.exec)")
            end
            channel.on_data do |ch1, data|
              stdout_data += data
              UI.command_output(data) if log
            end

            channel.on_extended_data do |ch2, type, data|
              # Only type 1 data is stderr (though no other types are defined by the standard)
              # See http://net-ssh.github.io/net-ssh/Net/SSH/Connection/Channel.html#method-i-on_extended_data
              stderr_data += data if type == 1
            end

            channel.on_request("exit-status") do |ch3, data|
              exit_code = data.read_long
            end

            channel.on_request("exit-signal") do |ch4, data|
              exit_signal = data.read_long
            end
          end
        end

        # Wait for all open channels to close
        ssh.loop
        { stdout: stdout_data, stderr: stderr_data, exit_code: exit_code, exit_signal: exit_signal }
      end

      def self.run(params)
        Actions.verify_gem!('net-ssh')
        require "net/ssh"

        Actions.lane_context[SharedValues::SSH_STDOUT_VALUE] = ""
        Actions.lane_context[SharedValues::SSH_STDERR_VALUE] = ""
        stdout = ""
        stderr = ""

        Net::SSH.start(params[:host], params[:username], { port: params[:port].to_i, password: params[:password] }) do |ssh|
          params[:commands].each do |cmd|
            UI.command(cmd) if params[:log]
            return_value = ssh_exec!(ssh, cmd, params[:log])
            if return_value[:exit_code] != 0
              UI.error("SSH Command failed '#{cmd}' Exit-Code: #{return_value[:exit_code]}")
              UI.user_error!("SSH Command failed")
            end

            stderr << return_value[:stderr]
            stdout << return_value[:stdout]
          end
        end
        command_word = params[:commands].count == 1 ? "command" : "commands"
        UI.success("Successfully executed #{params[:commands].count} #{command_word} on host #{params[:host]}")
        Actions.lane_context[SharedValues::SSH_STDOUT_VALUE] = stdout
        Actions.lane_context[SharedValues::SSH_STDERR_VALUE] = stderr
        return { stdout: Actions.lane_context[SharedValues::SSH_STDOUT_VALUE], stderr: Actions.lane_context[SharedValues::SSH_STDERR_VALUE] }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Allows remote command execution using ssh"
      end

      def self.details
        "Lets you execute remote commands via ssh using username/password or ssh-agent. If one of the commands in command-array returns non 0, it fails."
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
                                       sensitive: true,
                                       description: "Password",
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
          FastlaneCore::ConfigItem.new(key: :commands,
                                       short_option: "-C",
                                       env_name: "FL_SSH_COMMANDS",
                                       description: "Commands",
                                       optional: true,
                                       is_string: false,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :log,
                                       short_option: "-l",
                                       env_name: "FL_SSH_LOG",
                                       description: "Log commands and output",
                                       optional: true,
                                       default_value: true,
                                       is_string: false)
        ]
      end

      def self.output
        [
          ['SSH_STDOUT_VALUE', 'Holds the standard output of all commands'],
          ['SSH_STDERR_VALUE', 'Holds the standard error of all commands']
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
          'ssh(
            host: "dev.januschka.com",
            username: "root",
            commands: [
              "date",
              "echo 1 > /tmp/file1"
            ]
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
