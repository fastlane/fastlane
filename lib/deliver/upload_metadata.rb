module Deliver
  # upload description, rating, etc.
  class UploadMetadata
    LOCALISED_VALUES = [:description, :name, :keywords]

    def run(options)
      load_from_filesystem(options)

      app = options[:app]

      v = app.edit_version || app.live_version # TODO: get changes from work macbook here
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      LOCALISED_VALUES.each do |key|
        value = options[key]
        next unless value

        unless value.kind_of?(Hash)
          Helper.log.error "Error with provided '#{key}'. Must be a hash, the key being the language.".red
          next
        end

        value.each do |lng, value|
          language = Spaceship::Tunes::LanguageConverter.from_standard_to_itc(lng) # de-DE => German
          v.send(key)[language] = value
        end
      end

      Helper.log.info "Uploading metadata to iTunes Connect"
      v.save!
      Helper.log.info "Successfully uploaded initial set of metadata to iTunes Connect".green
    end

    # Loads the metadata files and stores them into the options object
    def load_from_filesystem(options)
      Dir.glob(File.join(options[:metadata_folder], "*")).each do |lng_folder|
        lng = File.basename(lng_folder)

        LOCALISED_VALUES.each do |key|
          path = File.join(lng_folder, "#{key}.txt")
          next unless File.exist?(path)
          Helper.log.info "Loading '#{path}'..."
          options[key] ||= {}
          options[key][lng] = File.read(path) # we can use the `lng`, it will be converted later
        end
      end
    end
  end
end
