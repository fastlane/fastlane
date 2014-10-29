require 'zip'
require 'plist'

module Deliver
  class IpaUploaderError < StandardError 
  end

  # This class takes care of preparing and uploading the given ipa file
  # Metadata + IPA file can not be handled in one file
  class IpaUploader < AppMetadata
    attr_accessor :app

    # Create a new uploader for one ipa file. This will only upload the ipa and no
    # other app metadata.
    # @param app (Deliver::App) The app for which the ipa should be uploaded for
    # @param dir (String) The path to where we can store (copy) the ipa file. Usually /tmp/
    # @param ipa_path (String) The path to the IPA file which should be uploaded
    # @param is_beta_build (Bool) If it's a beta build, it will be released to the testers, otherwise into production
    # @raise (IpaUploaderError) Is thrown when the ipa file was not found or is not valid
    def initialize(app, dir, ipa_path, is_beta_build)
      ipa_path.strip! # remove unused white spaces
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' not found") unless File.exists?(ipa_path)
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' is not a valid IPA file") unless ipa_path.include?".ipa"

      super(app, dir, false)

      @ipa_file = Deliver::MetadataItem.new(ipa_path)
      @is_beta_build = is_beta_build
    end

    # Fetches the app identifier (e.g. com.facebook.Facebook) from the given ipa file.
    def fetch_app_identifier
      plist = fetch_info_plist_file
      return plist['CFBundleIdentifier'] if plist
      return nil
    end

    # Fetches the app version from the given ipa file.
    def fetch_app_version
      plist = fetch_info_plist_file
      return plist['CFBundleShortVersionString'] if plist
      return nil
    end


    #####################################################
    # @!group Uploading the ipa file # TODO: pragma mark
    #####################################################

    # Actually upload the ipa file to Apple
    def upload!
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
        transporter.upload(@app, @metadata_dir)
      rescue Exception => ex
        is_okay = ex.to_s.include?"ready exists a binary upload with build" # this just means, the ipa is already online
      end

      if is_okay
        unless Helper.is_test?
          return publish_on_itunes_connect
        end
      end

      return is_okay
    end

    

    private
      # This method will trigger the iTunesConnect class to choose the latest build
      def publish_on_itunes_connect
        if not @is_beta_build
          # Publish onto Production
          Helper.log.info "Putting the latest build onto production."
          if self.app.itc.put_build_into_production!(self.app, self.fetch_app_version)
            if self.app.itc.submit_for_review!(self.app)
              Helper.log.info "Successfully deployed a new update of your app. You can now enjoy a good cold Club Mate.".green
              return true
            end
          end
        else
          # Distribute to beta testers
          Helper.log.info "Distributing the latest build to Beta Testers."
          if self.app.itc.put_build_into_beta_testing!(self.app, self.fetch_app_version)
            Helper.log.info "Successfully distributed a new beta build of your app.".green
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

      def fetch_info_plist_file
        Zip::File.open(@ipa_file.path) do |zipfile|
          zipfile.each do |file|
            if file.name.include?'Info.plist' # TODO: how can we find the actual name of the plist file?

              # The XML file has to be properly unpacked first
              tmp_path = "/tmp/deploytmp.plist"
              File.write(tmp_path, zipfile.read(file))
              system("plutil -convert xml1 #{tmp_path}")
              result = Plist::parse_xml(tmp_path)
              File.delete(tmp_path)

              return result
            end
          end
        end

        nil
      end

  end
end