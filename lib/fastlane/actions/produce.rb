module Fastlane
  module Actions
    module SharedValues
      PRODUCE_APPLE_ID = :PRODUCE_APPLE_ID
    end

    class ProduceAction
      def self.run(params)
        require 'produce'

        hash = params.first || {}
        raise "Parameter of produce must be a hash".red unless hash.kind_of?Hash

        hash.each do |key, value|
          ENV[key.to_s.upcase] = value.to_s
        end

        return if Helper.is_test?

        Dir.chdir(FastlaneFolder.path || Dir.pwd) do
          # This should be executed in the fastlane folder

          CredentialsManager::PasswordManager.shared_manager(ENV['PRODUCE_USERNAME']) if ENV['PRODUCE_USERNAME']
          Produce::Config.shared_config # to ask for missing information right in the beginning

          apple_id = Produce::Manager.start_producing.to_s

          Actions.lane_context[SharedValues::PRODUCE_APPLE_ID] = apple_id
          ENV["PRODUCE_APPLE_ID"] = apple_id
        end
      end
    end
  end
end
