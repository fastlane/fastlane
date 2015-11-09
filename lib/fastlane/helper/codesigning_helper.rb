module Fastlane
  module Helper
    class CodesigningHelper
      #####################################################
      # @!group General
      #####################################################

      def self.import_certificates

      end

      def self.import(params, item_path)
        command = "security import #{item_path.shellescape} -k ~/Library/Keychains/#{params[:keychain_name].shellescape}"
        command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
        command << " -T /usr/bin/security"
        begin
          Fastlane::Actions.sh(command, log: false)
        rescue => ex
          if ex.to_s.include?("SecKeychainItemImport: The specified item already exists in the keychain")
            return true
          else
            raise ex
          end
        end
        true
      end

      #####################################################
      # @!group Git Actions
      #####################################################
      def self.clone(git_url)
        dir = Dir.mktmpdir
        command = "git clone '#{git_url}' '#{dir}' --depth 1"
        Helper.log.info "Cloning remote git repo..."
        Actions.sh(command)

        return dir
      end

      def self.commit_changes(path)
        Dir.chdir(path) do
          return if `git status`.include?("nothing to commit")
          commands = []
          commands << "git add -A"
          commands << "git commit -m 'Automatic commit via fastlane'"
          commands << "git push origin master"

          commands.each do |command|
            Action.sh(command)
          end
        end

        FileUtils.rm_rf(path)
      end
    end
  end
end
