module Fastlane
  module Actions
    class RegisterDevicesAction
      UDID_REGEXP = /^\h{40}$/

      def self.run(params)
        require 'cupertino/provisioning_portal'
        require 'credentials_manager'
        require 'csv'

        params = params.first

        raise 'You must pass valid params to the register_devices action. Please check the readme.'.red if (params.nil? || params.empty?)

        devices       = params[:devices]
        devices_file  = params[:devices_file]
        team_id       = params[:team_id] || ENV['CUPERTINO_TEAM_ID'] || ENV['FASTLANE_TEAM_ID']
        username      = params[:username] || ENV['CUPERTINO_USERNAME']

        if devices
          device_objs = devices.map do |k, v|
            raise "Passed invalid UDID: #{v} for device: #{k}".red unless UDID_REGEXP =~ v

            Cupertino::ProvisioningPortal::Device.new(k, v)
          end
        elsif devices_file
          devices_file = CSV.read(File.expand_path(File.join('.', devices_file)), col_sep: "\t")

          raise 'Please provide a file according to the Apple Sample UDID file (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)'.red unless devices_file.first == ['Device ID', 'Device Name']

          device_objs = devices_file.drop(1).map do |device|
            raise 'Invalid device line, please provide a file according to the Apple Sample UDID file (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)'.red unless device.count == 2
            raise "Passed invalid UDID: #{device[0]} for device: #{device[1]}".red unless UDID_REGEXP =~ device[0]

            Cupertino::ProvisioningPortal::Device.new(device[1], device[0])
          end
        else
          raise 'You must pass either a valid `devices` or `devices_file`. Please check the readme.'.red
        end

        credentials = CredentialsManager::PasswordManager.shared_manager(username)

        agent = Cupertino::ProvisioningPortal::Agent.new
        agent.username = credentials.username
        agent.password = credentials.password
        agent.team_id = team_id if team_id

        Helper.log.info "Fetching list of currently registered devices..."        
        existing_devices = agent.list_devices
        new_devices = device_objs.select{ |device| !existing_devices.map(&:udid).include?(device.udid) } # calculate the diff based on the UDID

        if new_devices.count > 0
          Helper.log.info "Adding new devices..."
          agent.add_devices(*new_devices) rescue raise 'Could not add devices. Please ensure you have passed the correct username/password combination, as well as a valid team_id if a member of multiple teams.'.red

          Helper.log.info "Successfully registered #{new_devices.count} new devices. Total devices now registered: #{existing_devices.count + new_devices.count}!".green
        else
          Helper.log.info "Device list up to date, all #{device_objs.count} devices are already registered. Total devices registed: #{existing_devices.count}.".green
        end
      end
    end
  end
end
