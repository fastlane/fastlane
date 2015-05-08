module Fastlane
  module Actions
    class MailgunAction < Action

      def self.is_supported?(platform)
        true
      end

      def self.run(options)
        require 'rest_client'

        handle_exceptions(options)

        mailgunit(options[:mailgun_apikey],
                  options[:mailgun_sandbox_domain],
                  options[:mailgun_sandbox_postmaster],
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
                                       description: "Message of your mail"),
          FastlaneCore::ConfigItem.new(key: :subject,
                                       env_name: "MAILGUN_SUBJECT",
                                       description: "Subject of your mail",
                                       optional: true,
                                       is_string: true,
                                       default_value: "fastlane build"),
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
        text << "\n Git Author: #{Actions.git_author}"
        text << "\n Last Commit: #{Actions.last_git_commit}"
        text << "\n Success: #{success}"
      end

      def self.handle_exceptions(options)
          unless (options[:mailgun_apikey] rescue nil)
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_APIKEY\"] = \"a_valid_mailgun_apikey\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_APIKEY given.'.red
          end

          unless (options[:mailgun_sandbox_domain] rescue nil)
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_SANDBOX_DOMAIN\"] = \"a_valid_mailgun_sandbox_domain\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_SANDBOX_DOMAIN given.'.red
          end

          unless (options[:mailgun_sandbox_postmaster] rescue nil)
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
      end

      def self.mailgunit(api_key,sandbox_domain,sandbox_postmaster,to,subject,text)
        RestClient.post "https://api:#{api_key}@api.mailgun.net/v3/#{sandbox_domain}/messages",
        :from => "Mailgun Sandbox<#{sandbox_postmaster}>",
        :to => "#{to}",
        :subject => subject,
        :text => text
      end

    end
  end
end
