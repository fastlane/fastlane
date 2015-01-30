module Fastlane
  module Actions
    module SharedValues
      
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
          Produce::Manager.start_producing
        end
      end
    end
  end
end