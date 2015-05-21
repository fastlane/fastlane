require 'zip'
require 'plist'

module Deliver
  class IpaUploaderError < StandardError
  end

  IPA_UPLOAD_STRATEGY_APP_STORE = 1
  IPA_UPLOAD_STRATEGY_BETA_BUILD = 2
  IPA_UPLOAD_STRATEGY_JUST_UPLOAD = 3

  # This class takes care of preparing and uploading the given ipa file
  # Metadata + IPA file can not be handled in one file
  class IpaUploader < AppMetadata
    attr_accessor :app
    attr_accessor :publish_strategy

    # Create a new uploader for one ipa file. This will only upload the ipa and no
    # other app metadata.
    # @param app (Deliver::App) The app for which the ipa should be uploaded for
    # @param dir (String) The path to where we can store (copy) the ipa file. Usually /tmp/
    # @param ipa_path (String) The path to the IPA file which should be uploaded
    # @param publish_strategy (Int) If it's a beta build, it will be released to the testers.
    # If it's a production build it will be released into production. Otherwise no action.
    # @raise (IpaUploaderError) Is thrown when the ipa file was not found or is not valid
    def initialize(app, dir, ipa_path, publish_strategy)
      ipa_path.dup.strip! # remove unused white spaces
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' not found") unless File.exists?(ipa_path)
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' is not a valid IPA file") unless ipa_path.include?".ipa"

      super(app, dir, false)

      @ipa_file = Deliver::MetadataItem.new(ipa_path)
      @publish_strategy = publish_strategy
    end

    # Fetches the app identifier (e.g. com.facebook.Facebook) from the given ipa file.
    def fetch_app_identifier
      return IpaFileAnalyser.fetch_app_identifier(@ipa_file.path)
    end

    # Fetches the app version from the given ipa file.
    def fetch_app_version
      return IpaFileAnalyser.fetch_app_version(@ipa_file.path)
    end


    #####################################################
    # @!group Uploading the ipa file
    #####################################################

    # Actually upload the ipa file to Apple
    # @param submit_information (Hash) A hash containing submit information (export, content rights)
    def upload!(submit_information = nil)
      Helper.log.info "Uploading ipa file to iTunesConnect"
      build_document

      # Write the current XML state to disk
      folder_name = "#{@app.apple_id}.itmsp"
      path = "#{@metadata_dir}/#{folder_name}/"
      FileUtils.mkdir_p path

      File.write("#{path}/#{METADATA_FILE_NAME}", @data.to_xml)

      @ipa_file.store_file_inside_package(path)

      is_okay = true
      begin
        is_okay = transporter.upload(@app, @metadata_dir)
      rescue => ex
        Helper.log.debug ex
        is_okay = ex.to_s.include?"ready exists a binary upload with build" # this just means, the ipa is already online
      end

      if is_okay
        unless Helper.is_test?
          return publish_on_itunes_connect(submit_information)
        end
      end

      return is_okay
    end



    private
      # This method will trigger the iTunesConnect class to choose the latest build
      # @return Was it successful?
      def publish_on_itunes_connect(submit_information = nil)
        if @publish_strategy == IPA_UPLOAD_STRATEGY_APP_STORE
          return publish_production_build(submit_information)
        elsif @publish_strategy == IPA_UPLOAD_STRATEGY_BETA_BUILD
          return publish_beta_build
        else
          Helper.log.info "deliver will **not** submit the app for Review or for TestFlight distribution".yellow
          Helper.log.info "If you want to distribute the binary, don't define `skip_deploy` ".yellow

          if ENV["DELIVER_WHAT_TO_TEST"] or ENV["DELIVER_BETA_DESCRIPTION"] or ENV["DELIVER_BETA_FEEDBACK_EMAIL"]
            Helper.log.warn "---------------------------------------------------".yellow
            Helper.log.warn "You provided beta version metadata, but used the ".yellow
            Helper.log.warn "`skip_deploy` option when running deliver.".yellow
            Helper.log.warn "You have to remove `skip_deploy` to set a changelog".yellow
            Helper.log.warn "for TestFlight builds".yellow
            Helper.log.warn "---------------------------------------------------".yellow
          end
        end
        return true
      end

      def publish_beta_build
        # Distribute to beta testers
        Helper.log.info "Distributing the latest build to Beta Testers."
        if self.app.itc.put_build_into_beta_testing!(self.app, self.fetch_app_version)
          return true
        end
        return false
      end

      def publish_production_build(submit_information)
        # Publish onto Production
        Helper.log.info "Putting the latest build onto production."
        if self.app.itc.put_build_into_production!(self.app, self.fetch_app_version)
          if self.app.itc.submit_for_review!(self.app, submit_information)
            Helper.log.info "Successfully deployed a new update of your app. You can now enjoy a good cold Club Mate.".green
            return true
          end
        end
        return false
      end


      def build_document
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.package(xmlns: "http://apple.com/itunes/importer", version: "software4.7") {
            xml.software_assets(apple_id: @app.apple_id) {
              xml.asset(type: 'bundle') {

              }
            }
          }
        end

        @data = builder.doc
        asset = @data.xpath('//x:asset', "x" => Deliver::AppMetadata::ITUNES_NAMESPACE).first
        asset << @ipa_file.create_xml_node(@data)
      end
  end
end
