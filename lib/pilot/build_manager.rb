module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      raise "No ipa file given".red unless config[:ipa]

      Helper.log.info "Ready to upload new build to TestFlight (App: #{app.apple_id})...".green

      package_path = PackageBuilder.new.generate(apple_id: app.apple_id,
                                                 ipa_path: config[:ipa],
                                             package_path: "/tmp")

      transporter = FastlaneCore::ItunesTransporter.new(options[:username])
      result = transporter.upload(app.apple_id, package_path)

      if result
        Helper.log.info "Successfully uploaded the new binary to iTunes Connect"

        unless config[:skip_submission]
          uploaded_build = wait_for_processing_build
          distribute_build(uploaded_build, options)

          Helper.log.info "Successfully distributed build to beta testers 🚀"
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
    # @return [Build] The build that we just uploaded
    def wait_for_processing_build
      # the upload date of the new buid
      # we use it to identify the build

      start = Time.now
      wait_processing_interval = config[:wait_processing_interval].to_i
      latest_build = nil
      loop do
        Helper.log.info "Waiting for iTunes Connect to process the new build"
        sleep wait_processing_interval
        builds = app.all_processing_builds
        break if builds.count == 0
        latest_build = builds.last # store the latest pre-processing build here
      end

      full_build = nil

      while full_build.nil? || full_build.processing
        # Now get the full builds with a reference to the application and more
        # As the processing build from before doesn't have a refernece to the application
        full_build = app.build_trains[latest_build.train_version].builds.find do |b|
          b.build_version == latest_build.build_version
        end

        Helper.log.info "Waiting for iTunes Connect to finish processing the new build (#{full_build.train_version} - #{full_build.build_version})"
        sleep wait_processing_interval
      end

      if full_build
        minutes = ((Time.now - start) / 60).round
        Helper.log.info "Successfully finished processing the build".green
        Helper.log.info "You can now tweet: "
        Helper.log.info "iTunes Connect #iosprocessingtime #{minutes} minutes".yellow
        return full_build
      else
        raise "Error: Seems like iTunes Connect didn't properly pre-process the binary".red
      end
    end

    def distribute_build(uploaded_build, options)
      Helper.log.info "Distributing new build to testers"

      # First, set the changelog (if necessary)
      uploaded_build.update_build_information!(whats_new: options[:changelog])

      # Submit for internal beta testing
      type = options[:distribute_external] ? 'external' : 'internal'
      uploaded_build.build_train.update_testing_status!(true, type)
      return true
    end
  end
end
