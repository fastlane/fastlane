require 'credentials_manager/password_manager'
require 'credentials_manager/appfile_config'

module Deliver
  # Helps new user quickly adopt Deliver
  class DeliverfileCreator

    # This method will ask the user what he wants to do
    # @param deliver_path (String) The path in which the Deliverfile should be created
    # @param project_name (String) The default name of the project, which is used in the generated Deliverfile
    def self.create(deliver_path, project_name = nil)
      deliver_file_path = File.join(deliver_path, Deliver::Deliverfile::Deliverfile::FILE_NAME)
      raise "Deliverfile already exists at path '#{deliver_file_path}'. Run 'deliver' to use Deliver.".red if File.exists?(deliver_file_path)

      project_name ||= Dir.pwd.split("/").last

      if agree("Do you want Deliver to automatically create the Deliverfile for you based " + 
              "on your current app? The app has to be in the App Store to use this feature. (y/n)", true)

        puts "\n\nFirst, you need to login with your iTunesConnect credentials. ".yellow + 
          "\nThis is necessary to fetch the latest metadata from your app and use it to create a Deliverfile for you." + 
          "\nIf you have previously entered your credentials already, you will not be asked again."

        if CredentialsManager::PasswordManager.shared_manager.username and CredentialsManager::PasswordManager.shared_manager.password
          identifier = ((CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier) rescue '') || '')
          while identifier.length < 3
            identifier = ask("\nApp Identifier of your app (e.g. at.felixkrause.app_name): ")
          end

          self.create_based_on_identifier(deliver_path, identifier, project_name)
        else
          self.create_example_deliver_file(deliver_file_path, project_name)
        end
      else
        self.create_example_deliver_file(deliver_file_path, project_name)
      end
    end

    # This method is used, when the user does not want to automatically create the Deliverfile
    # @param path (String) The exact path (including the file name) in which the Deliverfile should be created
    # @param project_name (String) The default name of the project, which is used in the generated Deliverfile
    def self.create_example_deliver_file(path, project_name)
      example = File.read("#{gem_path}/lib/assets/DeliverfileExample")
      example.gsub!("[[APP_NAME]]", project_name)
      File.write(path, example)

      FileUtils.mkdir_p './screenshots/'

      puts "Successfully created new Deliverfile at '#{path}'".green
    end

    # This will download all the app metadata and store its data into JSON files
    # @param deliver_path (String) The directory in which the Deliverfile should be created
    # @param identifier (String) The app identifier we want to create Deliverfile based on
    # @param project_name (String) The default name of the project, which is used in the generated Deliverfile
    def self.create_based_on_identifier(deliver_path, identifier, project_name)
      app = Deliver::App.new(app_identifier: identifier)
      app.set_metadata_directory("/tmp") # we don't want to pollute the current folder
      app.metadata # this will download the latest app metadata
      
      file_path = [deliver_path, Deliver::Deliverfile::Deliverfile::FILE_NAME].join('/')
      json = generate_deliver_file(app, deliver_path, project_name)
      File.write(file_path, json)
      
      puts "Successfully created new Deliverfile at '#{file_path}'".green
    end

    private
      def self.gem_path
        if not Helper.is_test? and Gem::Specification::find_all_by_name('deliver').any?
          return Gem::Specification.find_by_name('deliver').gem_dir
        else
          return './'
        end
      end

      # This method takes care of creating a new 'deliver' folder, containg the app metadata 
      # and screenshots folders
      def self.generate_deliver_file(app, path, project_name)
        metadata_path = "#{path}/deliver/"
        FileUtils.mkdir_p metadata_path

        json = create_json_based_on_xml(app, metadata_path)

        json.each do |key, value|
          json[key].delete(:version_whats_new)
        end
        
        meta_path = "#{metadata_path}metadata.json"
        File.write(meta_path, JSON.pretty_generate(json))
        puts "Successfully created new metadata JSON file at '#{meta_path}'".green

        # Add a README to the screenshots folder
        File.write("#{metadata_path}screenshots/README.txt", File.read("#{gem_path}/lib/assets/ScreenshotsHelp"))

        # Generate the final Deliverfile here
        deliver = File.read("#{gem_path}/lib/assets/DeliverfileDefault")
        deliver.gsub!("[[APP_IDENTIFIER]]", app.app_identifier)
        deliver.gsub!("[[APP_NAME]]", project_name)
        deliver.gsub!("[[APPLE_ID]]", app.apple_id.to_s)
        deliver.gsub!("[[EMAIL]]", CredentialsManager::PasswordManager.shared_manager.username)

        return deliver
      end

      # Access the app metadata and use them to create a finished Deliverfile
      def self.create_json_based_on_xml(app, path)
        json = {}
        # Access the app metadata and use them to create a finished Deliverfile
        app_name = app.metadata.information.each do |locale, current|
          current.each do |key, value|
            if value and value.kind_of?Hash # that does not apply for screenshots, which is an array
              current[key] = value[:value] 
            else
              current.delete(key)
            end
          end

          json[locale] = current

          # Create an empty folder for the screenshots too
          FileUtils.mkdir_p "#{path}screenshots/#{locale}/"
        end

        return json
      end
  end
end