require_relative '../model'
module Spaceship
  class ConnectAPI
    class SandboxTester
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :password
      attr_accessor :confirm_password
      attr_accessor :secret_question
      attr_accessor :secret_answer
      attr_accessor :birth_date # 1980-03-01
      attr_accessor :app_store_territory
      attr_accessor :apple_pay_compatible

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "password" => "password",
        "confirmPassword" => "confirm_password",
        "secretQuestion" => "secret_question",
        "secretAnswer" => "secret_answer",
        "birthDate" => "birth_date",
        "appStoreTerritory" => "app_store_territory",
        "applePayCompatible" => "apple_pay_compatible"
      })

      def self.type
        return "sandboxTesters"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: 2000, sort: nil)
        resps = Spaceship::ConnectAPI.get_sandbox_testers(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(first_name: nil, last_name: nil, email: nil, password: nil, confirm_password: nil, secret_question: nil, secret_answer: nil, birth_date: nil, app_store_territory: nil)
        attributes = {
          firstName: first_name,
          lastName: last_name,
          email: email,
          password: password,
          confirmPassword: confirm_password,
          secretQuestion: secret_question,
          secretAnswer: secret_answer,
          birthDate: birth_date,
          appStoreTerritory: app_store_territory
        }
        return Spaceship::ConnectAPI.post_sandbox_tester(attributes: attributes).first
      end

      def delete!
        Spaceship::ConnectAPI.delete_sandbox_tester(sandbox_tester_id: id)
      end
    end
  end
end
