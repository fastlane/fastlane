module Deliver
	class Metadata
		attr_accessor :app

		def initialize(app)
			self.app = app
		end

		# the version to which we apply all the things
		def version
			self.app.edit_version
		end

		def update_localised_value(key, value)
			value.each do |lng, value|
				language = Spaceship::Tunes::LanguageConverter.from_standard_to_itc(lng) # de-DE => German
				value = value.join(" ") if value.kind_of?Array # e.g. keywords
				version.send(key)[language] = value
			end
		end
	end
end
