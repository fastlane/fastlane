require 'erb'
require 'ostruct'
require 'shenzhen'

module Fastlane
  module Actions

    module SharedValues
      IPA_OUTPUT_PATH = :IPA_OUTPUT_PATH
      DSYM_OUTPUT_PATH = :DSYM_OUTPUT_PATH
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

    ARGS_MAP = {
      file: '-f',
      dsym: '-d',
      access_key: '-a',
      secret_access_key: '-s',
      bucket: '--b',
      acl: '--acl',
      source: '--source-dir',
      path: '-P',
    }

    class S3Action
      def self.run(params)
        
        unless params.first.is_a? Hash
          return
        end

        # Other things that we need
        params = params.first
        s3_access_key = params[:access_key]
        s3_secret_access_key = params[:secret_access_key]
        s3_bucket = params[:bucket]
        ipa_file = params[:file]
        s3_path = params[:path]

        plist_template_path = params[:plist_template_path]
        html_template_path = params[:html_template_path]

        # Maps nice developer build parameters to Shenzhen args
        build_args = params_to_build_args(params)

        # If no dest directory given, default to current directory
        absolute_dest_directory ||= Dir.pwd

        if Helper.is_test?
          # Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = File.join(absolute_dest_directory, "test.ipa")
          # Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = File.join(absolute_dest_directory, "test.app.dSYM.zip")
          return build_args 
        end

        # Joins args into space delimited string
        build_args = build_args.join(' ')

        command = "ipa distribute:s3 #{build_args}"
        Helper.log.debug command
        Actions.sh command

        #####################################
        #
        # Does plist stuff
        #
        #####################################

        # Gets values for plist
        url_part = expand_path_with_substitutions_from_ipa_plist( ipa_file, s3_path )
        url = "https://s3.amazonaws.com/#{s3_bucket}/#{url_part}#{ipa_file}"

        bundle_id, bundle_version, title = nil
        Dir.mktmpdir do |dir|

          system "unzip -q #{ipa_file} -d #{dir} 2> /dev/null"
          plist = Dir["#{dir}/**/*.app/Info.plist"].last

          bundle_id = Shenzhen::PlistBuddy.print(plist, 'CFBundleIdentifier')
          bundle_version = Shenzhen::PlistBuddy.print(plist, 'CFBundleShortVersionString')
          title = Shenzhen::PlistBuddy.print(plist, 'CFBundleName')

        end

        plist_template_path ||= "#{Helper.gem_path}/lib/assets/s3_plist_template.erb"
        plist_template = File.read(plist_template_path)

        et = ErbalT.new({
          url: url,
          bundle_id: bundle_id,
          bundle_version: bundle_version,
          title: title
          })
        plist_render = et.render(plist_template)

        
        #####################################
        #
        # Does html stuff
        #
        #####################################

        html_template_path ||= "#{Helper.gem_path}/lib/assets/s3_html_template.erb"
        html_template = File.read(html_template_path)

        et = ErbalT.new({
          url: url,
          bundle_id: bundle_id,
          bundle_version: bundle_version,
          title: title
          })
        html_render = et.render(html_template)

        #####################################
        #
        # Does upload to s3 stuff
        #
        #####################################

        s3_client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
        )
        bucket = s3_client.buckets[s3_bucket]
        plist_file_name = "#{url_part}#{title}.plist"
        bucket.objects.create(plist_file_name, plist_render.to_s, :acl => :public_read)

        bucket.objects.create("index.html", html_render.to_s, :acl => :public_read)

        return true

      end

      def self.params_to_build_args(params)
        # Remove nil value params unless :clean or :archive
        params = params.delete_if { |k, v| (k != :clean && k != :archive ) && v.nil? }

        # Maps nice developer param names to Shenzhen's `ipa build` arguments
        params.collect do |k,v|
          v ||= ''
          if args = ARGS_MAP[k]
            value = (v.to_s.length > 0 ? "\"#{v}\"" : "")
            "#{ARGS_MAP[k]} #{value}".strip
          end
        end.compact
      end

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

    end

  end
end

class ErbalT < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end