module Fastlane
  module Actions
    class MailgunAction < Action

      def self.is_supported?(platform)
        true
      end

      def self.run(options)
        require 'rest_client'
        require 'erb'

        handle_exceptions(options)
        mailgunit(options)
      end

      def self.description
        "Send a success/error message to an email group"
      end

      def self.available_options
        [
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

      private
      def self.handle_exceptions(options)
          unless (options[:apikey] rescue nil)
            Helper.log.fatal "Please add 'ENV[\"MAILGUN_APIKEY\"] = \"a_valid_mailgun_apikey\"' to your Fastfile's `before_all` section.".red
            raise 'No MAILGUN_APIKEY given.'.red
          end

          unless (options[:postmaster] rescue nil)
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

          unless (options[:app_link] rescue nil)
            Helper.log.fatal "Please provide a valid :app_link  = \"a_valid_mailgun_app_link\"".red
            raise 'No MAILGUN_APP_LINK given.'.red
          end
      end

      def self.mailgunit(options)
        sandbox_domain = options[:postmaster].split("@").last
        RestClient.post "https://api:#{options[:apikey]}@api.mailgun.net/v3/#{sandbox_domain}/messages",
            :from => "Mailgun Sandbox<#{options[:postmaster]}>",
            :to => "#{options[:to]}",
            :subject => options[:subject],
            :html => mail_teplate(options)
      end


      def self.mail_teplate(options)
        html_template_path ||= "#{Helper.gem_path('fastlane')}/lib/assets/mailgun_html_template.erb"
        html_template = File.read(html_template_path)

        et = ErbalT.new({
          author: Actions.git_author,
          last_commit: Actions.last_git_commit,
          message: options[:message],
          app_link: options[:app_link],
          success: options[:success],
          ci_build_link: options[:ci_build_link]
          })
        et.render(html_template)
      end

    end
  end
end


class ErbalT < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end
