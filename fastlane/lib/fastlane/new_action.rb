module Fastlane
  # Guides the new user through creating a new action
  module NewAction
    def self.run(new_action_name: nil)
      name = new_action_name && check_action_name_from_args(new_action_name) ? new_action_name : fetch_name
      generate_action(name)
    end

    def self.fetch_name
      puts("Must be lower case, and use a '_' between words. Do not use '.'".green)
      puts("examples: 'testflight', 'upload_to_s3'".green)
      name = UI.input("Name of your action: ")
      until name_valid?(name)
        puts("Name is invalid. Please ensure the name is all lowercase, free of spaces and without special characters! Try again.")
        name = UI.input("Name of your action: ")
      end
      name
    end

    def self.generate_action(name)
      template = File.read("#{Fastlane::ROOT}/lib/assets/custom_action_template.rb")
      template.gsub!('[[NAME]]', name)
      template.gsub!('[[NAME_UP]]', name.upcase)
      template.gsub!('[[NAME_CLASS]]', name.fastlane_class + 'Action')

      actions_path = File.join((FastlaneCore::FastlaneFolder.path || Dir.pwd), 'actions')
      FileUtils.mkdir_p(actions_path) unless File.directory?(actions_path)

      path = File.join(actions_path, "#{name}.rb")
      File.write(path, template)
      UI.success("Created new action file '#{path}'. Edit it to implement your custom action.")
    end

    def self.check_action_name_from_args(new_action_name)
      if name_valid?(new_action_name)
        new_action_name
      else
        puts("Name is invalid. Please ensure the name is all lowercase, free of spaces and without special characters! Try again.")
      end
    end

    def self.name_valid?(name)
      name =~ /^[a-z0-9_]+$/
    end
    private_class_method :name_valid?
  end
end
