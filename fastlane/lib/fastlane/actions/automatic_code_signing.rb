require 'xcodeproj'
module Fastlane
  module Actions
    class AutomaticCodeSigningAction < Action
      def self.run(params)
        FastlaneCore::PrintTable.print_values(config: params, title: "Summary for Automatic Codesigning")
        path = params[:path]
        path = File.join(File.expand_path(path), "project.pbxproj")

        project = Xcodeproj::Project.open(params[:path])
        UI.user_error!("Could not find path to project config '#{path}'. Pass the path to your project (not workspace)!") unless File.exist?(path)
        UI.message("Updating the Automatic Codesigning flag to #{params[:use_automatic_signing] ? 'enabled' : 'disabled'} for the given project '#{path}'")

        unless project.root_object.attributes["TargetAttributes"]
          UI.error("Seems to be a very old project file format")
          UI.error("PLEASE BACKUP ALL FILES before doing this.")
          if ENV["FL_PROJECT_SIGNING_FORCE_UPGRADE"] || UI.confirm("Proceed with upgrade to xcode8 format?")
            UI.important("Upgrading project to use xcode8 signing stuff")
            unless params[:team_id]
              UI.important("TEAM id is not set")
              UI.error!("Provide :team_id")
            end

            # set upgrade market to xcdoe8
            project.root_object.attributes["LastUpgradeCheck"] = "0800"
            target_attr_hash = {}

            # for each target add the TargetAttributes Entry
            # setting team id, and signing mode
            project.root_object.targets.each do |target|
              new_hash = {}
              new_hash["CreatedOnToolsVersion"] = "8.0"
              new_hash["DevelopmentTeam"] = params[:team_id]
              new_hash["ProvisioningStyle"] = params[:use_automatic_signing] ? 'Automatic' : 'Manual'
              target_attr_hash[target.uuid] = new_hash
            end

            # for each configuration set a signing identity
            project.build_configurations.each do |config|
              config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = config.name == "Release" ? 'iPhone Distribution' : "iPhone Development"
            end
            project.root_object.attributes["TargetAttributes"] = target_attr_hash
          else
            UI.user_error!("canceled upgrade")
          end
        end

        target_dictionary = project.targets.map { |f| { name: f.name, uuid: f.uuid } }
        changed_targets = []
        project.root_object.attributes["TargetAttributes"].each do |target, sett|
          found_target = target_dictionary.detect { |h| h[:uuid] == target }
          if params[:targets]
            # get target name
            unless params[:targets].include?(found_target[:name])
              UI.important("Skipping #{found_target[:name]} not selected (#{params[:targets].join(',')})")
              next
            end
          end

          sett["ProvisioningStyle"] = params[:use_automatic_signing] ? 'Automatic' : 'Manual'
          sett["DevelopmentTeam"] = params[:team_id] if params[:team_id]
          changed_targets << found_target[:name]
        end
        project.save

        if changed_targets.length == 0
          UI.important("None of the specified targets has been modified")
          UI.important("available targets:")
          target_dictionary.each do |tar|
            UI.important("\t* #{tar[:name]}")
          end
        else
          UI.success("Successfully updated project settings to use ProvisioningStyle '#{params[:use_automatic_signing] ? 'Automatic' : 'Manual'}'")
          UI.success("Modified Targets:")
          changed_targets.each do |tar|
            UI.success("\t * #{tar}")
          end
        end
        params[:use_automatic_signing]
      end
      
      def self.alias_used(action_alias, params)
        params[:use_automatic_signing] = true if action_alias == "enable_automatic_code_signing"
      end

      def self.aliases
        ["enable_automatic_code_signing", "disable_automatic_code_signing"]
      end
      
      def self.description
        "Updates the Xcode 8 Automatic Codesigning Flag"
      end

      def self.details
        "Updates the Xcode 8 Automatic Codesigning Flag of all targets in the project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_PROJECT_SIGNING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       verify_block: proc do |value|
                                         UI.user_error!("Path is invalid") unless File.exist?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_automatic_signing,
                                       env_name: "FL_PROJECT_USE_AUTOMATIC_SIGNING",
                                       description: "Defines if project should use automatic signing",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                        env_name: "FASTLANE_TEAM_ID",
                                        optional: true,
                                        description: "Team ID, is used when upgrading project",
                                        is_string: true),
          FastlaneCore::ConfigItem.new(key: :targets,
                                       env_name: "FL_PROJECT_SIGNING_TARGETS",
                                       optional: true,
                                       type: Array,
                                       description: "Specify targets you want to toggle the signing mech. (default to all targets)",
                                       is_string: false)
        ]
      end

      def self.output
      end
      
      def self.example_code
        [
          '# enable automatic code signing
          enable_automatic_code_signing',
          'enable_automatic_code_signing(
            path: "demo-project/demo/demo.xcodeproj"
          )',
          '# disable automatic code signing
          disable_automatic_code_signing',
          'disable_automatic_code_signing(
            path: "demo-project/demo/demo.xcodeproj"
          )',
          '# also set team id
          disable_automatic_code_signing(
            path: "demo-project/demo/demo.xcodeproj",
            team_id: "XXXX"
          )',
          '# Only specific targets
            disable_automatic_code_signing(
              path: "demo-project/demo/demo.xcodeproj",
              use_automatic_signing: false,
              targets: ["demo"]
            )
          ',
          ' # via generic action
          automatic_code_signing(
            path: "demo-project/demo/demo.xcodeproj"
            use_automatic_signing: false
          )',
          'automatic_code_signing(
            path: "demo-project/demo/demo.xcodeproj"
            use_automatic_signing: true
          )'

        ]
      end
      
      def self.category
        :code_signing
      end
      
      def self.return_value
        "The current status (boolean) of codesigning after modification"
      end

      def self.authors
        ["mathiasAichinger", "hjanuschka"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end