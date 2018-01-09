module Fastlane
  class MarkdownDocsGenerator
    attr_accessor :categories

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions

      self.work
    end

    def work
      fill_built_in_actions
    end

    def fill_built_in_actions
      self.categories = {}

      Fastlane::Action::AVAILABLE_CATEGORIES.each { |a| self.categories[readable_category_name(a)] = {} }

      # Fill categories with all built-in actions
      ActionsList.all_actions do |action|
        readable = readable_category_name(action.category)

        if self.categories[readable].kind_of?(Hash)
          self.categories[readable][number_of_launches_for_action(action.action_name)] = action
        else
          UI.error("Action '#{action.name}' doesn't contain category information... skipping")
        end
      end
    end

    def number_of_launches_for_action(action_name)
      found = all_actions_from_enhancer.find { |c| c['action'] == action_name.to_s }

      return found["index"] if found
      return 10_000 + rand # new actions that we've never tracked before will be shown at the bottom of the page, need `rand` to not overwrite them
    end

    def all_actions_from_enhancer
      require 'json'
      @_launches ||= JSON.parse(File.read(File.join(Fastlane::ROOT, "assets/action_ranking.json"))) # root because we're in a temporary directory here
    end

    def custom_action_docs_path
      "lib/fastlane/actions/docs/"
    end

    def load_custom_action_md(action)
      # check if there is a custom detail view in markdown available in the fastlane code base
      custom_file_location = File.join(Fastlane::ROOT, custom_action_docs_path, "#{action.action_name}.md")
      if File.exist?(custom_file_location)
        UI.verbose("Using custom md file for action #{action.action_name}")
        return File.read(custom_file_location)
      end
      return nil
    end

    def generate!(target_path: nil)
      require 'yaml'
      FileUtils.mkdir_p(target_path)
      docs_dir = File.join(target_path, "docs")

      # Generate actions.md
      template = File.join(Fastlane::ROOT, "lib/assets/Actions.md.erb")
      result = ERB.new(File.read(template), 0, '-').result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system
      File.write(File.join(docs_dir, "actions.md"), result)

      # Generate actions sub pages (e.g. actions/slather.md, actions/scan.md)
      all_actions_ref_yml = []
      FileUtils.mkdir_p(File.join(docs_dir, "actions"))
      ActionsList.all_actions do |action|
        # Make sure to always assign `@custom_content`, as we're in a loop and `@` is needed for the `erb`
        @custom_content = load_custom_action_md(action)

        if action.superclass != Fastlane::Action
          # This means, the current method is an alias
          # meaning we're gonna look if the parent class
          # as a custom md file.
          # e.g. `deliver.rb` super class is `upload_to_app_store.rb`
          @custom_content ||= load_custom_action_md(action.superclass)
        end

        template = File.join(Fastlane::ROOT, "lib/assets/ActionDetails.md.erb")
        @action = action # to provide a reference in the .html.erb template
        result = ERB.new(File.read(template), 0, '-').result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system

        file_name = File.join("actions", "#{action.action_name}.md")
        File.write(File.join(docs_dir, file_name), result)

        all_actions_ref_yml << { action.action_name => file_name }
      end

      # Modify the mkdocs.yml to list all the actions
      mkdocs_yml_path = File.join(target_path, "mkdocs.yml")
      raise "Could not find mkdocs.yml in #{target_path}, make sure to point to the fastlane/docs repo" unless File.exist?(mkdocs_yml_path)
      mkdocs_yml = YAML.load_file(mkdocs_yml_path)
      hidden_actions_array = mkdocs_yml["pages"].find { |p| !p["_Actions"].nil? }
      hidden_actions_array["_Actions"] = all_actions_ref_yml
      File.write(mkdocs_yml_path, mkdocs_yml.to_yaml)

      # Copy over the assets from the `actions/docs/assets` directory
      Dir[File.join(custom_action_docs_path, "assets", "*")].each do |current_asset_path|
        UI.message("Copying asset #{current_asset_path}")
        FileUtils.cp(current_asset_path, File.join(docs_dir, "img", "actions", File.basename(current_asset_path)))
      end

      UI.success("Generated new docs on path #{target_path}")
    end

    private

    def readable_category_name(category_symbol)
      case category_symbol
      when :misc
        "Misc"
      when :source_control
        "Source Control"
      when :notifications
        "Notifications"
      when :code_signing
        "Code Signing"
      when :documentation
        "Documentation"
      when :testing
        "Testing"
      when :building
        "Building"
      when :push
        "Push"
      when :screenshots
        "Screenshots"
      when :project
        "Project"
      when :beta
        "Beta"
      when :production
        "Releasing your app"
      when :deprecated
        "Deprecated"
      else
        category_symbol.to_s.capitalize
      end
    end
  end
end
