require 'erb'
require 'ostruct'
require 'shenzhen'

module Fastlane
  module Actions

    module SharedValues
      S3_IPA_OUTPUT_PATH = :S3_IPA_OUTPUT_PATH
      S3_DSYM_OUTPUT_PATH = :S3_DSYM_OUTPUT_PATH
      S3_PLIST_OUTPUT_PATH = :S3_PLIST_OUTPUT_PATH
      S3_HTML_OUTPUT_PATH = :S3_HTML_OUTPUT_PATH
    end

    # -f, --file FILE      .ipa file for the build 
    # -d, --dsym FILE      zipped .dsym package for the build 
    # -a, --access-key-id ACCESS_KEY_ID AWS Access Key ID 
    # -s, --secret-access-key SECRET_ACCESS_KEY AWS Secret Access Key 
    # -b, --bucket BUCKET  S3 bucket 
    # --[no-]create        Create bucket if it doesn't already exist 
    # -r, --region REGION  Optional AWS region (for bucket creation) 
    # --acl ACL            Uploaded object permissions e.g public_read (default), private, public_read_write, authenticated_read 
    # --source-dir SOURCE  Optional source directory e.g. ./build 
    # -P, --path PATH      S3 'path'. Values from Info.plist will be substituded for keys wrapped in {}  
    #              eg. "/path/to/folder/{CFBundleVersion}/" could be evaluated as "/path/to/folder/1.0.0/" 

    S3_ARGS_MAP = {
      ipa: '-f',
      dsym: '-d',
      access_key: '-a',
      secret_access_key: '-s',
      bucket: '-b',
      region: '-r',
      acl: '--acl',
      source: '--source-dir',
      path: '-P',
    }

    class S3Action < Action
      def self.run(params)
        
        params[0] ||= {}
        unless params.first.is_a?Hash
          raise "Please pass the required information to the s3 action." 
        end

        # Other things that we need
        params = params.first

        params[:access_key] ||= ENV['S3_ACCESS_KEY'] || ENV['AWS_ACCESS_KEY_ID']
        params[:secret_access_key] ||= ENV['S3_SECRET_ACCESS_KEY'] || ENV['AWS_SECRET_ACCESS_KEY']
        params[:bucket] ||= ENV['S3_BUCKET'] || ENV['AWS_BUCKET_NAME']
        params[:region] ||= ENV['S3_REGION'] || ENV['AWS_REGION']
        params[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        params[:dsym] ||= Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]
        params[:path] ||= 'v{CFBundleShortVersionString}_b{CFBundleVersion}/'

        # Maps nice developer build parameters to Shenzhen args
        build_args = params_to_build_args(params)

        # Pulling parameters for other uses
        s3_subdomain = params[:region] ? "s3-#{params[:region]}" : "s3"
        s3_access_key = params[:access_key]
        s3_secret_access_key = params[:secret_access_key]
        s3_bucket = params[:bucket]
        ipa_file = params[:ipa]
        dsym_file = params[:dsym]
        s3_path = params[:path]

        raise "No S3 access key given, pass using `access_key: 'key'`".red unless s3_access_key.to_s.length > 0
        raise "No S3 secret access key given, pass using `secret_access_key: 'secret key'`".red unless s3_secret_access_key.to_s.length > 0
        raise "No S3 bucket given, pass using `bucket: 'bucket'`".red unless s3_bucket.to_s.length > 0
        raise "No IPA file path given, pass using `ipa: 'ipa path'`".red unless ipa_file.to_s.length > 0

        plist_template_path = params[:plist_template_path]
        html_template_path = params[:html_template_path]
        html_file_name = params[:html_file_name]

        if Helper.is_test?
          return build_args 
        end

        # Joins args into space delimited string
        build_args = build_args.join(' ')

        command = "ipa distribute:s3 #{build_args}"
        Helper.log.debug command
        Actions.sh command

        #####################################
        #
        # html and plist building
        #
        #####################################

        # Gets info used for the plist
        bundle_id, bundle_version, title = get_ipa_info( ipa_file )

        # Gets URL for IPA file
        url_part = expand_path_with_substitutions_from_ipa_plist( ipa_file, s3_path )
        ipa_file_name = File.basename(ipa_file)
        ipa_url = "https://#{s3_subdomain}.amazonaws.com/#{s3_bucket}/#{url_part}#{ipa_file_name}"
        dsym_url = "https://#{s3_subdomain}.amazonaws.com/#{s3_bucket}/#{url_part}#{dsym_file}" if dsym_file

        # Setting action and environment variables
        Actions.lane_context[SharedValues::S3_IPA_OUTPUT_PATH] = ipa_url
        ENV[SharedValues::S3_IPA_OUTPUT_PATH.to_s] = ipa_url

        if dsym_file
          Actions.lane_context[SharedValues::S3_DSYM_OUTPUT_PATH] = dsym_url
          ENV[SharedValues::S3_DSYM_OUTPUT_PATH.to_s] = dsym_url
        end

        # Creating plist and html names
        plist_file_name = "#{url_part}#{title}.plist"
        plist_url = "https://#{s3_subdomain}.amazonaws.com/#{s3_bucket}/#{plist_file_name}"

        html_file_name ||= "index.html"
        html_url = "https://#{s3_subdomain}.amazonaws.com/#{s3_bucket}/#{html_file_name}"

        # Creates plist from template
        plist_template_path ||= "#{Helper.gem_path('fastlane')}/lib/assets/s3_plist_template.erb"
        plist_template = File.read(plist_template_path)

        et = ErbalT.new({
          url: ipa_url,
          bundle_id: bundle_id,
          bundle_version: bundle_version,
          title: title
          })
        plist_render = et.render(plist_template)

        # Creates html from template
        html_template_path ||= "#{Helper.gem_path('fastlane')}/lib/assets/s3_html_template.erb"
        html_template = File.read(html_template_path)

        et = ErbalT.new({
          url: plist_url,
          bundle_id: bundle_id,
          bundle_version: bundle_version,
          title: title
          })
        html_render = et.render(html_template)

        #####################################
        #
        # html and plist uploading
        #
        #####################################

        upload_plist_and_html_to_s3(
          s3_access_key,
          s3_secret_access_key,
          s3_bucket,
          plist_file_name,
          plist_render,
          html_file_name,
          html_render
          )        

        return true

      end

      def self.params_to_build_args(params)
        # Remove nil value params unless :clean or :archive
        params = params.delete_if { |k, v| (k != :clean && k != :archive ) && v.nil? }

        # Maps nice developer param names to Shenzhen's `ipa build` arguments
        params.collect do |k,v|
          v ||= ''
          if args = S3_ARGS_MAP[k]
            value = (v.to_s.length > 0 ? "\"#{v}\"" : "")
            "#{S3_ARGS_MAP[k]} #{value}".strip
          end
        end.compact
      end

      def self.upload_plist_and_html_to_s3(s3_access_key, s3_secret_access_key, s3_bucket, plist_file_name, plist_render, html_file_name, html_render)
        require 'aws-sdk'
        s3_client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
        )
        bucket = s3_client.buckets[s3_bucket]

        plist_obj = bucket.objects.create(plist_file_name, plist_render.to_s, :acl => :public_read)
        html_obj = bucket.objects.create(html_file_name, html_render.to_s, :acl => :public_read)

        # Setting actionand environment variables
        Actions.lane_context[SharedValues::S3_PLIST_OUTPUT_PATH] = plist_obj.public_url.to_s
        ENV[SharedValues::S3_PLIST_OUTPUT_PATH.to_s] = plist_obj.public_url.to_s

        Actions.lane_context[SharedValues::S3_HTML_OUTPUT_PATH] = html_obj.public_url.to_s
        ENV[SharedValues::S3_HTML_OUTPUT_PATH.to_s] = html_obj.public_url.to_s

        Helper.log.info "Successfully uploaded ipa file to '#{html_obj.public_url.to_s}'".green
      end

      #
      # NOT a fan of this as this was taken straight from Shenzhen
      # https://github.com/nomad/shenzhen/blob/986792db5d4d16a80c865a2748ee96ba63644821/lib/shenzhen/plugins/s3.rb#L32
      # 
      # Need to find a way to not use this copied method
      #
      # AGAIN, I am not happy about this right now.
      # Using this for prototype reasons.
      #
      def self.expand_path_with_substitutions_from_ipa_plist(ipa, path)
        substitutions = path.scan(/\{CFBundle[^}]+\}/)
        return path if substitutions.empty?

        Dir.mktmpdir do |dir|
          system "unzip -q #{ipa} -d #{dir} 2> /dev/null"

          plist = Dir["#{dir}/**/*.app/Info.plist"].last

          substitutions.uniq.each do |substitution|
            key = substitution[1...-1]
            value = Shenzhen::PlistBuddy.print(plist, key)

            path.gsub!(Regexp.new(substitution), value) if value
          end
        end

        return path
      end

      def self.get_ipa_info(ipa_file)
        bundle_id, bundle_version, title = nil
        Dir.mktmpdir do |dir|

          system "unzip -q #{ipa_file} -d #{dir} 2> /dev/null"
          plist = Dir["#{dir}/**/*.app/Info.plist"].last

          bundle_id = Shenzhen::PlistBuddy.print(plist, 'CFBundleIdentifier')
          bundle_version = Shenzhen::PlistBuddy.print(plist, 'CFBundleShortVersionString')
          title = Shenzhen::PlistBuddy.print(plist, 'CFBundleName')

        end
        return bundle_id, bundle_version, title
      end

    end

  end
end

class ErbalT < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end