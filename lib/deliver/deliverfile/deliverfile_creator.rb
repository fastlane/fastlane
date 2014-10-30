module Deliver
  # Helps new user quickly adopt Deliver
  class DeliverfileCreator

    # This method will ask the user what he wants to do
    def self.create(path)
      raise "Deliverfile already exists at path '#{deliver_path}'. Run 'deliver' to use Deliver." if File.exists?(deliver_path)

      if agree("Do you want Deliver to automatically create the Deliverfile for you based " + 
              "on your current app? (y/n)", true)

        puts "\n\nFirst, you need to login with your iTunesConnect credentials. ".yellow + 
          "\nThis is necessary to fetch the latest metadata from your app and use it to create a Deliverfile for you." + 
          "\nIf you have previously entered your credentials already, you will not be asked again."

        if Deliver::PasswordManager.new.username and Deliver::PasswordManager.new.password
          identifier = ''
          while identifier.length < 3
            identifier = ask("\nApp Identifier of your app (e.g. at.felixkrause.app_name): ")
          end

          self.create_based_on_identifier(deliver_path, identifier)
        else
          self.create_example_deliver_file(deliver_path)
        end
      else
        self.create_example_deliver_file(deliver_path)
      end
    end

    # This method is used, when the user does not want to automatically create the Deliverfile
    def self.create_example_deliver_file(path)
      example = File.read("#{gem_path}/lib/assets/DeliverfileExample")
      example.gsub!("[[APP_NAME]]", Dir.pwd.split("/").last)
      File.write(path, example)

      puts "Successfully created new Deliverfile at '#{path}'".green
    end

    # This will download all the app metadata and store its data into JSON files
    def self.create_based_on_identifier(deliver_path, identifier)
      app = Deliver::App.new(app_identifier: identifier)
      app.set_metadata_directory("/tmp") # we don't want to pollute the current folder
      app.metadata # this will download the latest app metadata
      
      path = './deliver/'
      FileUtils.mkdir_p path

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

      meta_path = "#{path}metadata.json"
      File.write(meta_path, json.to_json)
      puts "Successfully created new metadata JSON file at '#{meta_path}'".green

      # Add a README to the screenshots folder
      File.write("#{path}screenshots/README.txt", File.read("#{gem_path}/lib/assets/ScreenshotsHelp"))

      # Generate the final Deliverfile here
      deliver = File.read("#{gem_path}/lib/assets/DeliverfileDefault")
      deliver.gsub!("[[APP_IDENTIFIER]]", identifier)
      deliver.gsub!("[[APP_NAME]]", Dir.pwd.split("/").last)


      File.write(deliver_path, deliver)
      puts "Successfully created new Deliverfile at '#{deliver_path}'".green
    end

    private
      def self.gem_path
        Gem::Specification.find_by_name("deliver").gem_dir
      end
  end
end