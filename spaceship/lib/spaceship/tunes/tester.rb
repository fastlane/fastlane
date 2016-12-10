module Spaceship
  module Tunes
    class Tester < TunesBase
      # @return (String) The identifier of this tester, provided by iTunes Connect
      # @example
      #   "60f858b4-60a8-428a-963a-f943a3d68d17"
      attr_accessor :tester_id

      # @return (String) The email of this tester
      # @example
      #   "tester@spaceship.com"
      attr_accessor :email

      # @return (String) The first name of this tester
      # @example
      #   "Cary"
      attr_accessor :first_name

      # @return (String) The last name of this tester
      # @example
      #   "Bennett"
      attr_accessor :last_name

      # @return (Array) an array of associated groups
      # @example
      #    [{
      #      "id": "e031e048-4f0f-4c1e-8d8a-a5341a267986",
      #      "name": {
      #        "value": "My App Testers"
      #      }
      #    }]
      attr_accessor :groups

      # @return (Array) An array of registered devices for this user
      # @example
      #    [{
      #      "model": "iPhone 6",
      #      "os": "iOS",
      #      "osVersion": "8.3",
      #      "name": null
      #    }]
      attr_accessor :devices

      # Information about the most recent beta install
      # @return [Integer] The ID of the most recently installed app
      attr_accessor :latest_install_app_id

      # @return [Integer] Date of the last install of this tester
      #   Number of seconds since 1970
      attr_accessor :latest_install_date

      # @return [Integer] The build number of the last installed build
      attr_accessor :latest_installed_build_number

      # @return [Integer] The version number of the last installed build
      attr_accessor :latest_installed_version_number

      attr_mapping(
        'testerId' => :tester_id,
        'emailAddress.value' => :email,
        'firstName.value' => :first_name,
        'lastName.value' => :last_name,
        'groups' => :groups,
        'devices' => :devices,
        'latestInstalledAppAdamId' => :latest_install_app_id,
        'latestInstalledDate' => :latest_install_date,
        'latestInstalledVersion' => :latest_installed_version_number,
        'latestInstalledShortVersion' => :latest_installed_build_number
      )

      class << self
        # @return (Hash) All urls for the ITC used for web requests
        def url
          raise "You have to use a subclass: Internal or External"
        end

        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all beta testers available for this account
        def all
          client.testers(self).map { |tester| self.factory(tester) }
        end

        # @return (Spaceship::Tunes::Tester) Returns the tester matching the parameter
        #   as either the Tester id or email
        # @param identifier (String) (required): Value used to filter the tester, case insensitive
        def find(identifier)
          all.find do |tester|
            (tester.tester_id.to_s.casecmp(identifier.to_s).zero? or tester.email.to_s.casecmp(identifier.to_s).zero?)
          end
        end

        def groups
          client.groups
        end

        # Create new tester in iTunes Connect
        # @param email (String) (required): The email of the new tester
        # @param first_name (String) (optional): The first name of the new tester
        # @param last_name (String) (optional): The last name of the new tester
        # @param groups (Array) (option): Names/IDs of existing groups for the new tester
        # @example
        #   Spaceship::Tunes::Tester.external.create!(email: "tester@mathiascarignani.com", first_name: "Cary", last_name:"Bennett", groups:["Testers"])
        # @return (Tester): The newly created tester
        def create!(email: nil, first_name: nil, last_name: nil, groups: nil)
          data = client.create_tester!(tester: self,
                                        email: email,
                                   first_name: first_name,
                                    last_name: last_name,
                                       groups: groups)
          self.factory(data)
        end

        #####################################################
        # @!group App
        #####################################################

        # @return (Array) Returns all beta testers available for this account filtered by app
        # @param app_id (String) (required): The app id to filter the testers
        def all_by_app(app_id)
          client.testers_by_app(self, app_id).map { |tester| self.factory(tester) }
        end

        # @return (Spaceship::Tunes::Tester) Returns the tester matching the parameter
        #   as either the Tester id or email
        # @param app_id (String) (required): The app id to filter the testers
        # @param identifier (String) (required): Value used to filter the tester, case insensitive
        def find_by_app(app_id, identifier)
          all_by_app(app_id).find do |tester|
            (tester.tester_id.to_s.casecmp(identifier.to_s).zero? or tester.email.to_s.casecmp(identifier.to_s).zero?)
          end
        end

        # Add all testers to the app received
        # @param app_id (String) (required): The app id to filter the testers
        def add_all_to_app!(app_id)
          all.each do |tester|
            begin
              tester.add_to_app!(app_id)
            rescue => ex
              if ex.to_s.include? "testerEmailExistsInternal" or ex.to_s.include? "duplicate.email"
                # That's a non-relevant error message by iTC
                # ignore that
              else
                raise ex
              end
            end
          end
        end
      end

      def setup
        self.devices ||= [] # by default, an empty array instead of nil
      end

      #####################################################
      # @!group Subclasses
      #####################################################
      class External < Tester
        def self.url(app_id = nil)
          {
            index: "ra/users/pre/ext",
            index_by_app: "ra/user/externalTesters/#{app_id}/",
            create: "ra/users/pre/create",
            delete: "ra/users/pre/ext/delete",
            update_by_app: "ra/user/externalTesters/#{app_id}/"
          }
        end
      end

      class Internal < Tester
        def self.url(app_id = nil)
          {
            index: "ra/users/pre/int",
            index_by_app: "ra/user/internalTesters/#{app_id}/",
            create: nil,
            delete: nil,
            update_by_app: "ra/user/internalTesters/#{app_id}/"
          }
        end
      end

      # Delete current tester
      def delete!
        client.delete_tester!(self)
      end

      #####################################################
      # @!group App
      #####################################################

      # Add current tester to list of the app testers
      # @param app_id (String) (required): The id of the application to which want to modify the list
      def add_to_app!(app_id)
        client.add_tester_to_app!(self, app_id)
      end

      # Remove current tester from list of the app testers
      # @param app_id (String) (required): The id of the application to which want to modify the list
      def remove_from_app!(app_id)
        client.remove_tester_from_app!(self, app_id)
      end

      #####################################################
      # @!group Helpers
      #####################################################

      # Return a list of the Tester's group, if any
      # @return
      def groups_list(separator = ', ')
        if groups
          group_names = groups.map { |group| group["name"]["value"] }
          group_names.join(separator)
        end
      end
    end

    class SandboxTester < TunesBase
      # @return (String) The email of this tester
      # @example
      #   "tester@spaceship.com"
      attr_accessor :email

      # @return (String) The first name of this tester
      # @example
      #   "Cary"
      attr_accessor :first_name

      # @return (String) The last name of this tester
      # @example
      #   "Bennett"
      attr_accessor :last_name

      # @return (String) The two-letter country code of this tester
      # @example
      #   "US"
      attr_accessor :country

      attr_mapping(
        'emailAddress.value' => :email,
        'firstName.value' => :first_name,
        'lastName.value' => :last_name,
        'storeFront.value' => :country
      )

      def self.url
        {
          index:  "ra/users/iap",
          create: "ra/users/iap/add",
          delete: "ra/users/iap/delete"
        }
      end

      def self.all
        client.sandbox_testers(self).map { |tester| self.new(tester) }
      end

      def self.create!(email: nil, password: nil, first_name: 'Test', last_name: 'Test', country: 'US')
        data = client.create_sandbox_tester!(
          tester_class: self,
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name,
          country: country
        )
        self.new(data)
      end

      def self.delete!(emails)
        client.delete_sandbox_testers!(self, emails)
      end

      def self.delete_all!
        delete!(self.all.map(&:email))
      end
    end
  end
end
