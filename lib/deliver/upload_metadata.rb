module Deliver
  # upload description, rating, etc.
  class UploadMetadata
    LOCALISED_VALUES = [:description, :name, :keywords]

    def run(options)
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
          value = value.join(" ") if value.kind_of? Array # e.g. keywords
          v.send(key)[language] = value
        end
      end

      Helper.log.info "Uploading new metadata (name, description, etc....)"
      v.save!
      Helper.log.info "Successfully uploaded initial set of metadata to iTunes Connect".green
    end
  end
end
