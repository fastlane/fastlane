module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      Helper.log.info "Ready to upload new build to TestFlight (App: #{app.apple_id})...".green

      package_path = PackageBuilder.new.generate(apple_id: app.apple_id, 
                                                 ipa_path: config[:ipa],
                                             package_path: "/tmp")

      result = FastlaneCore::ItunesTransporter.new.upload(app.apple_id, package_path)
      if result
        Helper.log.info "Successfully uploaded the new binary to iTunes Connect"

        unless config[:skip_submission]
          upload_date = wait_for_processing_build
          distribute_build(upload_date)

          Helper.log.info "Successfully distribute build to beta testers 🚀"
        end
      else
        raise "Error uploading ipa file, more information see above".red
      end
    end

    def list(options)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = ask("App Identifier: ")
      end

      rows = app.all_processing_builds.collect { |build| describe_build(build) }
      rows = rows + app.builds.collect { |build| describe_build(build) }

      puts Terminal::Table.new(
        title: "#{app.name} Builds".green,
        headings: ["Version #", "Build #", "Testing", "Installs", "Sessions"],
        rows: rows
      )
    end

    private
      def describe_build(build)
        row = [build.train_version, 
               build.build_version,
               build.testing_status,
               build.install_count,
               build.session_count]

        return row
      end

      # This method will takes care of checking for the processing builds every few seconds
      # @return [Integer] The upload date
      def wait_for_processing_build
        # the upload date of the new buid
        # we use it to identify the build
        upload_date = nil
        loop do
          Helper.log.info "Waiting for iTunes Connect to process the new build"
          sleep 5
          builds = app.all_processing_builds
          break if builds.count == 0
          upload_date = builds.last.upload_date
        end

        if upload_date
          Helper.log.info "Build successfully processed by iTunes Connect".green
          return upload_date
        else
          raise "Error: Seems like iTunes Connect didn't properly pre-process the binary".red
        end
      end

      def distribute_build(upload_date)
        Helper.log.info "Distributing new build to testers"
        
        current_build = app.builds.find do |build|
          build.upload_date == upload_date
        end

        # First, enable TestFlight beta testing for this train
        current_build.build_train.update_testing_status!(true)
      end
  end
end