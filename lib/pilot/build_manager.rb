module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      Helper.log.info "Ready to upload new build to TestFlight (App: #{app.apple_id})...".green

      package_path = PackageBuilder.new.generate(apple_id: app.apple_id,
                                                 ipa_path: config[:ipa],
                                             package_path: "/tmp")

      transporter = FastlaneCore::ItunesTransporter.new(options[:username])
      result = transporter.upload(app.apple_id, package_path)

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

      builds = app.all_processing_builds + app.builds
      # sort by upload_date
      builds.sort! {|a, b| a.upload_date <=> b.upload_date }
      rows = builds.collect { |build| describe_build(build) }

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
        sleep 30
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

      # We try this multiple times, as it sometimes takes some time
      # to process the binary
      100.times do
        current_build = app.builds.find do |build|
          build.upload_date == upload_date
        end

        if current_build
          current_build.build_train.update_testing_status!(true, 'external')
          return true
        else
          Helper.log.info "Binary is not yet available online..."
          sleep 30
        end
      end

      Helper.log.error "Build is not visible on iTunes Connect any more - couldn't distribute to testers.".red
      Helper.log.error "You can run `pilot --skip_submission` to only upload the binary without distributing.".red
      raise "Error distributing the binary"
    end
  end
end
