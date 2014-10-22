require 'pry'

module Deliver
  class DeliverfileCreator

    # This method will ask the user what he wants to do
    def self.create(path)
      raise "Deliverfile already exists at path '#{deliver_path}'" if File.exists?(deliver_path)

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
      example = File.read("./lib/assets/DeliverfileExample")
      example.gsub!("[[APP_NAME]]", Dir.pwd.split("/").last)
      File.write(path, example)

      puts "Successfully created new Deliverfile at '#{path}'".green
    end

    def self.create_based_on_identifier(deliver_path, identifier)
      puts "To Implement"
    end
  end
end