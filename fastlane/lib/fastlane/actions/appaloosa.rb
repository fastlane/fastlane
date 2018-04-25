module Fastlane
  module Actions
    class AppaloosaAction < Action
      APPALOOSA_SERVER = 'https://www.appaloosa-store.com/api/v2'.freeze
      def self.run(params)
        api_key = params[:api_token]
        store_id = params[:store_id]
        binary = params[:binary]
        remove_extra_screenshots_file(params[:screenshots])
        binary_url = get_binary_link(binary, api_key, store_id, params[:group_ids])
        return if binary_url.nil?
        screenshots_url = get_screenshots_links(api_key, store_id, params[:screenshots], params[:locale], params[:device])
        upload_on_appaloosa(api_key, store_id, binary_url, screenshots_url, params[:group_ids], params[:description])
      end

      def self.get_binary_link(binary, api_key, store_id, group_ids)
        key_s3 = upload_on_s3(binary, api_key, store_id, group_ids)
        return if key_s3.nil?
        get_s3_url(api_key, store_id, key_s3)
      end

      def self.upload_on_s3(file, api_key, store_id, group_ids = '')
        file_name = file.split('/').last
        uri = URI("#{APPALOOSA_SERVER}/upload_services/presign_form")
        params = { file: file_name, store_id: store_id, group_ids: group_ids, api_key: api_key }
        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        presign_form_response = http.request(Net::HTTP::Get.new(uri.request_uri))
        json_res = JSON.parse(presign_form_response.body)
        return if error_detected(json_res['errors'])
        s3_sign = json_res['s3_sign']
        path = json_res['path']
        uri = URI.parse(Base64.decode64(s3_sign))
        File.open(file, 'rb') do |f|
          http = Net::HTTP.new(uri.host)
          put = Net::HTTP::Put.new(uri.request_uri)
          put.body = f.read
          put['content-type'] = ''
          http.request(put)
        end
        path
      end

      def self.get_s3_url(api_key, store_id, path)
        uri = URI("#{APPALOOSA_SERVER}/#{store_id}/upload_services/url_for_download")
        params = { store_id: store_id, api_key: api_key, key: path }
        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        url_for_download_response = http.request(Net::HTTP::Get.new(uri.request_uri))
        if invalid_response?(url_for_download_response)
          UI.user_error!("ERROR: A problem occurred with your API token and your store id. Please try again.")
        end
        json_res = JSON.parse(url_for_download_response.body)
        return if error_detected(json_res['errors'])
        json_res['binary_url']
      end

      def self.remove_extra_screenshots_file(screenshots_env)
        extra_file = "#{screenshots_env}/screenshots.html"
        File.unlink(extra_file) if File.exist?(extra_file)
      end

      def self.upload_screenshots(screenshots, api_key, store_id)
        return if screenshots.nil?
        list = []
        list << screenshots.map do |screen|
          upload_on_s3(screen, api_key, store_id)
        end
      end

      def self.get_uploaded_links(uploaded_screenshots, api_key, store_id)
        return if uploaded_screenshots.nil?
        urls = []
        urls << uploaded_screenshots.flatten.map do |url|
          get_s3_url(api_key, store_id, url)
        end
      end

      def self.get_screenshots_links(api_key, store_id, screenshots_path, locale, device)
        screenshots = get_screenshots(screenshots_path, locale, device)
        return if screenshots.nil?
        uploaded = upload_screenshots(screenshots, api_key, store_id)
        links = get_uploaded_links(uploaded, api_key, store_id)
        links.kind_of?(Array) ? links.flatten : nil
      end

      def self.get_screenshots(screenshots_path, locale, device)
        get_env_value('screenshots').nil? ? locale = '' : locale.concat('/')
        device.nil? ? device = '' : device.concat('-')
        screenshots_path.strip.empty? ? nil : screenshots_list(screenshots_path, locale, device)
      end

      def self.screenshots_list(path, locale, device)
        return warning_detected("screenshots folder not found") unless Dir.exist?("#{path}/#{locale}")
        list = Dir.entries("#{path}/#{locale}") - ['.', '..']
        list.map do |screen|
          next if screen.match(device).nil?
          "#{path}/#{locale}#{screen}" unless Dir.exist?("#{path}/#{locale}#{screen}")
        end.compact
      end

      def self.upload_on_appaloosa(api_key, store_id, binary_path, screenshots, group_ids, description)
        screenshots = all_screenshots_links(screenshots)
        uri = URI("#{APPALOOSA_SERVER}/#{store_id}/mobile_application_updates/upload")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        req.body = { store_id: store_id,
                     api_key: api_key,
                     mobile_application_update: {
                       description: description,
                       binary_path: binary_path,
                       screenshot1: screenshots[0],
                       screenshot2: screenshots[1],
                       screenshot3: screenshots[2],
                       screenshot4: screenshots[3],
                       screenshot5: screenshots[4],
                       group_ids: group_ids,
                       provider: 'fastlane'
                     } }.to_json
        uoa_response = http.request(req)
        json_res = JSON.parse(uoa_response.body)
        if json_res['errors']
          UI.error("App: #{json_res['errors']}")
        else
          UI.success("Binary processing: Check your app': #{json_res['link']}")
        end
      end

      def self.all_screenshots_links(screenshots)
        if screenshots.nil?
          screens = %w(screenshot1 screenshot2 screenshot3 screenshot4 screenshot5)
          screenshots = screens.map do |_k, _v|
            ''
          end
        else
          missings = 5 - screenshots.count
          (1..missings).map do |_i|
            screenshots << ''
          end
        end
        screenshots
      end

      def self.get_env_value(option)
        available_options.map do |opt|
          opt if opt.key == option.to_sym
        end.compact[0].default_value
      end

      def self.error_detected(errors)
        if errors
          UI.user_error!("ERROR: #{errors}")
        else
          false
        end
      end

      def self.warning_detected(warning)
        UI.important("WARNING: #{warning}")
        nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Upload your app to Appaloosa Store'
      end

      def self.details
        [
          "Appaloosa is a private mobile application store. This action offers a quick deployment on the platform.",
          "You can create an account, push to your existing account, or manage your user groups.",
          "We accept iOS and Android applications."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary,
                                       env_name: 'FL_APPALOOSA_BINARY',
                                       description: 'Binary path. Optional for ipa if you use the `ipa` or `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa || apk file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: 'FL_APPALOOSA_API_TOKEN',
                                       sensitive: true,
                                       description: "Your API token"),
          FastlaneCore::ConfigItem.new(key: :store_id,
                                       env_name: 'FL_APPALOOSA_STORE_ID',
                                       description: "Your Store id"),
          FastlaneCore::ConfigItem.new(key: :group_ids,
                                       env_name: 'FL_APPALOOSA_GROUPS',
                                       description: 'Your app is limited to special users? Give us the group ids',
                                       default_value: '',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :screenshots,
                                       env_name: 'FL_APPALOOSA_SCREENSHOTS',
                                       description: 'Add some screenshots application to your store or hit [enter]',
                                       default_value: Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :locale,
                                       env_name: 'FL_APPALOOSA_LOCALE',
                                       description: 'Select the folder locale for your screenshots',
                                       default_value: 'en-US',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :device,
                                       env_name: 'FL_APPALOOSA_DEVICE',
                                       description: 'Select the device format for your screenshots',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: 'FL_APPALOOSA_DESCRIPTION',
                                       description: 'Your app description',
                                       optional: true)
        ]
      end

      def self.authors
        ['Appaloosa']
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include?(platform)
      end

      def self.invalid_response?(url_for_download_response)
        url_for_download_response.kind_of?(Net::HTTPNotFound) ||
          url_for_download_response.kind_of?(Net::HTTPForbidden)
      end

      def self.example_code
        [
          "appaloosa(
            # Path tor your IPA or APK
            binary: '/path/to/binary.ipa',
            # You can find your store’s id at the bottom of the “Settings” page of your store
            store_id: 'your_store_id',
            # You can find your api_token at the bottom of the “Settings” page of your store
            api_token: 'your_api_key',
            # User group_ids visibility, if it's not specified we'll publish the app for all users in your store'
            group_ids: '112, 232, 387',
            # You can use fastlane/snapshot or specify your own screenshots folder.
            # If you use snapshot please specify a local and a device to upload your screenshots from.
            # When multiple values are specified in the Snapfile, we default to 'en-US'
            locale: 'en-US',
            # By default, the screenshots from the last device will be used
            device: 'iPhone6',
            # Screenshots' filenames should start with device's name like 'iphone6-s1.png' if device specified
            screenshots: '/path/to_your/screenshots'
          )"
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
