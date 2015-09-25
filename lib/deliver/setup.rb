module Deliver
  class Setup
    def run(options)
      containing = (File.directory?("fastlane") ? 'fastlane' : '.')
      create_based_on_identifier(containing, options)
    end

    # This will download all the app metadata and store its data into JSON files
    # @param deliver_path (String) The directory in which the Deliverfile should be created
    # @param identifier (String) The app identifier we want to create Deliverfile based on
    # @param project_name (String) The default name of the project, which is used in the generated Deliverfile
    def create_based_on_identifier(deliver_path, options)
      file_path = File.join(deliver_path, 'Deliverfile')
      data = generate_deliver_file(deliver_path, options)
      File.write(file_path, data)

      download_screenshots(deliver_path, options)

      # Add a README to the screenshots folder
      FileUtils.mkdir_p File.join(deliver_path, 'screenshots') # just in case the fetching didn't work
      File.write(File.join(deliver_path, 'screenshots', 'README.txt'), File.read("#{Helper.gem_path('deliver')}/lib/assets/ScreenshotsHelp"))

      Helper.log.info "Successfully created new Deliverfile at path '#{file_path}'".green
    end

    private

    # This method takes care of creating a new 'deliver' folder, containg the app metadata
    # and screenshots folders
    def generate_deliver_file(deliver_path, options)
      v = options[:app].latest_version
      generate_metadata_files(v, deliver_path)

      # Generate the final Deliverfile here
      gem_path = Helper.gem_path('deliver')
      deliver = File.read("#{gem_path}/lib/assets/DeliverfileDefault")
      deliver.gsub!("[[APP_IDENTIFIER]]", options[:app].bundle_id)
      deliver.gsub!("[[USERNAME]]", Spaceship::Tunes.client.user)

      return deliver
    end

    def generate_metadata_files(v, deliver_path)
      app_details = v.application.details
      containing = File.join(deliver_path, 'metadata')

      # All the localised metadata
      (UploadMetadata::LOCALISED_VERSION_VALUES + UploadMetadata::LOCALISED_APP_VALUES).each do |key|
        v.description.languages.each do |language|
          if UploadMetadata::LOCALISED_VERSION_VALUES.include?(key)
            content = v.send(key)[language]
          else
            content = app_details.send(key)[language]
          end

          resulting_path = File.join(containing, language, "#{key}.txt")
          FileUtils.mkdir_p(File.expand_path('..', resulting_path))
          File.write(resulting_path, content)
          Helper.log.debug "Writing to '#{resulting_path}'"
        end
      end

      # All non-localised metadata
      (UploadMetadata::NON_LOCALISED_VERSION_VALUES + UploadMetadata::NON_LOCALISED_APP_VALUES).each do |key|
        if UploadMetadata::NON_LOCALISED_VERSION_VALUES.include?(key)
          content = v.send(key)
        else
          content = app_details.send(key)
        end

        resulting_path = File.join(containing, "#{key}.txt")
        File.write(resulting_path, content)
        Helper.log.debug "Writing to '#{resulting_path}'"
      end

      puts "Successfully created new configuration files.".green
    end

    def download_screenshots(deliver_path, options)
      FileUtils.mkdir_p(File.join(deliver_path, 'screenshots'))
      begin
        Deliver::DownloadScreenshots.run(options, deliver_path)
      rescue Exception => ex
        Helper.log.error ex
        Helper.log.error "Couldn't download already existing screenshots from iTunesConnect. You have to add them manually!".red
      end
    end
  end
end
