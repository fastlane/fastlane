module Fastlane
  module Actions
    class MailgunAction < Action
      def self.git_author
        s = `git log --name-status HEAD^..HEAD`
        s = s.match(/Author:.*<(.*)>/)[1]
        return s if s.to_s.length > 0
        return nil
      rescue
        return nil
      end

      def self.last_git_commit
        s = `git log -1 --pretty=%B`.strip
        return s if s.to_s.length > 0
        nil
      end

      def self.is_supported?(platform)
        true
      end

      # As there is a text limit in the notifications, we are
      # usually interested in the last part of the message
      # e.g. for tests
      def self.trim_message(message)
        # We want the last 7000 characters, instead of the first 7000, as the error is at the bottom
        start_index = [message.length - 7000, 0].max
        message = message[start_index..-1]
        message
      end

      def self.run(options)
        require 'rest_client'

        handle_exceptions(options)

        options[:message] = self.trim_message(options[:message].to_s || '')

        mailgunit(ENV['MAILGUN_APIKEY'],
                  ENV['MAILGUN_SANDBOX_DOMAIN'],
                  ENV['MAILGUN_SANDBOX_POSTMASTER'],
                  options[:to],
                  options[:subject],
                  compose_mail(options[:message],options[:success]))

      end

      def self.description
        "Send a success/error message to an email group"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :mailgun_sandbox_domain,
                                       env_name: "MAILGUN_SANDBOX_DOMAIN",
                                       description: "Mailgun sandbox domain for your mail"),
          FastlaneCore::ConfigItem.new(key: :mailgun_sandbox_postmaster,
                                       env_name: "MAILGUN_SANDBOX_POSTMASTER",
                                       description: "Mailgun sandbox domain postmaster for your mail"),
          FastlaneCore::ConfigItem.new(key: :mailgun_apikey,
                                       env_name: "MAILGUN_APIKEY",
                                       description: "Mailgun apikey for your mail"),
          FastlaneCore::ConfigItem.new(key: :to,
                                       env_name: "MAILGUN_TO",
                                       description: "Destination of your mail"),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "MAILGUN_MESSAGE",
                                       description: "Text of your mail"),
          FastlaneCore::ConfigItem.new(key: :subject,
                                       env_name: "MAILGUN_SUBJECT",
                                       description: "Subject of your mail"),
          FastlaneCore::ConfigItem.new(key: :success,
                                      env_name: "MAILGUN_SUCCESS",
                                      description: "Was this build successful? (true/false)",
                                      optional: true,
                                      default_value: true,
                                      is_string: false)

        ]
      end

      def self.author
        "thiagolioy"
      end

      private
      def self.compose_mail(text,success)
        text << "\n Git Author: #{git_author}"
        text << "\n Last Commit: #{last_git_commit}"
        text << "\n Success: #{success}"
      end

      def self.handle_exceptions(options)
          unless ENV['MAILGUN_APIKEY']
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_APIKEY\"] = \"a_valid_mailgun_apikey\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_APIKEY given.'.red
          end

          unless ENV['MAILGUN_SANDBOX_DOMAIN']
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_SANDBOX_DOMAIN\"] = \"a_valid_mailgun_sandbox_domain\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_SANDBOX_DOMAIN given.'.red
          end

          unless ENV['MAILGUN_SANDBOX_POSTMASTER']
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_SANDBOX_POSTMASTER\"] = \"a_valid_mailgun_sandbox_postmaster\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_SANDBOX_POSTMASTER given.'.red
          end

          unless (options[:to] rescue nil)
            Helper.log.fatal "Please provide a valid :to  = \"a_valid_mailgun_to\"".red
            raise 'No MAILGUN_TO given.'.red
          end

          unless (options[:message] rescue nil)
            Helper.log.fatal "Please provide a valid :message  = \"a_valid_mailgun_text\"".red
            raise 'No MAILGUN_MESSAGE given.'.red
          end

          unless (options[:subject] rescue nil)
            Helper.log.fatal "Please provide a valid :subject  = \"a_valid_mailgun_subject\"".red
            raise 'No MAILGUN_SUBJECT given.'.red
          end
      end

      def self.mailgunit(api_key,sandbox_domain,sandbox_postmaster,to,subject,text)
        RestClient.post "https://api:#{api_key}@api.mailgun.net/v3/#{sandbox_domain}/messages",
        :from => "Mailgun Sandbox <#{sandbox_postmaster}>",
        :to => "#{to}",
        :subject => subject,
        :text => text
      end

    end
  end
end
