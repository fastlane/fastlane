require 'credentials_manager/password_manager'
require 'credentials_manager/appfile_config'
require 'deliver/itunes_connect/itunes_connect'

module Deliver
  # Helps new user quickly adopt Deliver
  class DeliverfileCreator

    # This method will ask the user what he wants to do
    # @param deliver_path (String) The path in which the Deliverfile should be created (this automatically takes care if it's in the fastlane folder)
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
            identifier = ask("\nApp Identifier of your app (e.g. com.krausefx.app_name): ")
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
      gem_path = Helper.gem_path('deliver')
      example = File.read("#{gem_path}/lib/assets/DeliverfileExample")
      example.gsub!("[[APP_NAME]]", project_name)
      File.write(path, example)

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

      version_number = app.metadata.fetch_value("//x:version").first["string"] # fetch the latest app version
      
      file_path = File.join(deliver_path, Deliver::Deliverfile::Deliverfile::FILE_NAME)
      json = generate_deliver_file(app, deliver_path, project_name, version_number)
      File.write(file_path, json)

      FileUtils.mkdir_p File.join(deliver_path, 'screenshots')
      begin
        Helper.log.info "Downloading all previously used app screenshots.".green
        ItunesConnect.new.download_existing_screenshots(app, deliver_path)
      rescue Exception => ex
        Helper.log.error ex
        Helper.log.error "Couldn't download already existing screenshots from iTunesConnect. You have to add them manually!".red
      end

      # Add a README to the screenshots folder
      FileUtils.mkdir_p File.join(deliver_path, 'screenshots') # just in case the fetching didn't work
      File.write(File.join(deliver_path, 'screenshots', 'README.txt'), File.read("#{Helper.gem_path('deliver')}/lib/assets/ScreenshotsHelp"))
      
      Helper.log.info "Successfully created new Deliverfile at '#{file_path}'".green
    end

    private
      # This method takes care of creating a new 'deliver' folder, containg the app metadata 
      # and screenshots folders
      def self.generate_deliver_file(app, path, project_name, version_number)
        FileUtils.mkdir_p path rescue nil # never mind if it's already there

        json = create_json_based_on_xml(app, path)

        json.each do |language, value|
          folder = File.join(path, "metadata", language)
          FileUtils.mkdir_p(folder)
          value.each do |key, content|
            content = content.join("\n") if key == :keywords
            File.write(File.join(folder, "#{key}.txt"), content)
          end
          Helper.log.info "Successfully downloaded existing metadata for language #{language}"
        end
        
        puts "Successfully created new configuration files at '#{File.join(path, 'metadata')}'".green

        gem_path = Helper.gem_path('deliver')

        # Generate the final Deliverfile here
        deliver = File.read("#{gem_path}/lib/assets/DeliverfileDefault")
        deliver.gsub!("[[APP_IDENTIFIER]]", app.app_identifier)
        deliver.gsub!("[[APP_NAME]]", project_name)
        deliver.gsub!("[[APPLE_ID]]", app.apple_id.to_s)
        deliver.gsub!("[[EMAIL]]", CredentialsManager::PasswordManager.shared_manager.username)
        deliver.gsub!("[[APP_VERSION]]", version_number)

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
        end

        return json
      end
  end
end