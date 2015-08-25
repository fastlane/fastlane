require 'fastlane/erb_template_helper'

module Fastlane
  module Actions
    class MailgunAction < Action

      def self.is_supported?(platform)
        true
      end

      def self.run(options)
        require 'rest_client'
        handle_params_transition(options)
        mailgunit(options)
      end

      def self.description
        "Send a success/error message to an email group"
      end

      def self.available_options
        [
          # This is here just for while due to the transition, not needed anymore
          FastlaneCore::ConfigItem.new(key: :mailgun_sandbox_domain,
                                       env_name: "MAILGUN_SANDBOX_POSTMASTER",
                                       optional: true,
                                       description: "Mailgun sandbox domain postmaster for your mail. Please use postmaster instead"),
          # This is here just for while due to the transition, should use postmaster instead
          FastlaneCore::ConfigItem.new(key: :mailgun_sandbox_postmaster,
                                       env_name: "MAILGUN_SANDBOX_POSTMASTER",
                                       optional: true,
                                       description: "Mailgun sandbox domain postmaster for your mail. Please use postmaster instead"),
          # This is here just for while due to the transition, should use apikey instead
          FastlaneCore::ConfigItem.new(key: :mailgun_apikey,
                                       env_name: "MAILGUN_APIKEY",
                                       optional: true,
                                       description: "Mailgun apikey for your mail. Please use postmaster instead"),

          FastlaneCore::ConfigItem.new(key: :postmaster,
                                       env_name: "MAILGUN_SANDBOX_POSTMASTER",
                                       description: "Mailgun sandbox domain postmaster for your mail"),
          FastlaneCore::ConfigItem.new(key: :apikey,
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
                                      is_string: false),
          FastlaneCore::ConfigItem.new(key: :app_link,
                                      env_name: "MAILGUN_APP_LINK",
                                      description: "App Release link",
                                      optional: false,
                                      is_string: true),
          FastlaneCore::ConfigItem.new(key: :ci_build_link,
                                      env_name: "MAILGUN_CI_BUILD_LINK",
                                      description: "CI Build Link",
                                      optional: true,
                                      is_string: true)

        ]
      end

      def self.author
        "thiagolioy"
      end

      def self.handle_params_transition(options)
        options[:postmaster] = options[:mailgun_sandbox_postmaster] if options[:mailgun_sandbox_postmaster]
        puts "\nUsing :mailgun_sandbox_postmaster is deprecated, please change to :postmaster".yellow

        options[:apikey] = options[:mailgun_apikey] if options[:mailgun_apikey]
        puts "\nUsing :mailgun_apikey is deprecated, please change to :apikey".yellow
      end

      def self.mailgunit(options)
        sandbox_domain = options[:postmaster].split("@").last
        RestClient.post "https://api:#{options[:apikey]}@api.mailgun.net/v3/#{sandbox_domain}/messages",
                        from: "Mailgun Sandbox<#{options[:postmaster]}>",
                        to: "#{options[:to]}",
                        subject: options[:subject],
                        html: mail_teplate(options)
        mail_teplate(options)
      end

      def self.mail_teplate(options)
        hash = {
          author: Actions.git_author,
          last_commit: Actions.last_git_commit,
          message: options[:message],
          app_link: options[:app_link]
        }
        hash[:success] = options[:success] if options[:success]
        hash[:ci_build_link] = options[:success] if options[:ci_build_link]
        Fastlane::ErbTemplateHelper.render(
          Fastlane::ErbTemplateHelper.load("mailgun_html_template"),
          hash
        )
      end

    end
  end
end
