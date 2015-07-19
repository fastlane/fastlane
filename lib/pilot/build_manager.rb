module Pilot
  class BuildManager < Manager
    def run(options)
      super(options)

      Helper.log.info "Ready to upload new build to TestFlight (App: #{config[:apple_id]})...".green

      package_path = PackageBuilder.new.generate(apple_id: config[:apple_id], 
                                                 ipa_path: config[:ipa],
                                             package_path: "/tmp") # TODO: Config

      result = FastlaneCore::ItunesTransporter.new.upload(config[:apple_id], package_path)
      if result
        Helper.log.info "Successfully uploaded the new binary to iTunes Connect"

        wait_for_processing_build unless config[:skip_submission]
      else
        raise "Error uploading ipa file, more information see above".red
      end
    end

    # This method will takes care of checking for the processing builds every few seconds
    def wait_for_processing_build
      loop do
        Helper.log.info "Waiting for build to be processed by iTunes Connect"
        sleep 5
        builds = fetch_processing_builds
        break if builds == 0
      end

      require 'pry'; binding.pry
    end

    # @return [Array] A list of all processing builds from all build trains
    def fetch_processing_builds
      builds = []
      app.build_trains.each do |version_number, train|
        train.processing_builds.each do |build|
          builds << build
        end
      end

      return builds
    end
  end
end