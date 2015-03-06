module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_UDID = :SIGH_UDID
    end

    class SighAction
      def self.run(params)
        require 'sigh'
        require 'sigh/options'
        require 'credentials_manager/appfile_config'

        Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, (params.first || {}))
        path = Sigh::DeveloperCenter.new.run



        path = File.expand_path(File.join('.', File.basename(path)))
        if path
          if Sigh.config[:filename]
            file_name = Sigh.config[:filename]
          else
            file_name = File.basename(path)
          end
          
          output = File.join(Sigh.config[:output_path].gsub("~", ENV["HOME"]), file_name)
          (FileUtils.mv(path, output) rescue nil) # in case it already exists
          system("open -g '#{output}'") unless Sigh.config[:skip_install]
          puts output.green
          path = output
        end

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
        Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile
      end
    end
  end
end
