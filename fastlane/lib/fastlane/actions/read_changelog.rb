module Fastlane
  module Actions
    module SharedValues
      READ_CHANGELOG_SECTION_CONTENT = :READ_CHANGELOG_SECTION_CONTENT
    end

    class ReadChangelogAction < Action

      def self.run(params)
        changelog_path = params[:changelog_path] unless params[:changelog_path].to_s.empty?
        UI.error("CHANGELOG.md at path '#{changelog_path}' does not exist") unless File.exist?(changelog_path)

        section_identifier = params[:section_identifier] unless params[:section_identifier].to_s.empty?
        escaped_section_identifier = section_identifier[/\[(.*?)\]/, 1]

        excluded_markdown_elements = params[:excluded_markdown_elements]

        UI.message "Starting to read #{section_identifier} section from '#{changelog_path}'"

        section_content = ""
        found_section = false
        File.open(changelog_path, "r") do |file|
          file.each_line do |line|
            if found_section
              break if line =~ /\#{2}\s?\[(.*?)\]/
              if !excluded_markdown_elements.nil? && !excluded_markdown_elements.empty?
                markdownless_line = remove_markdown(line, excluded_markdown_elements)
                section_content.concat(markdownless_line)
              else
                section_content.concat(line)
              end
            end

            if line =~ /\#{2}\s?\[#{escaped_section_identifier}\]/
              found_section = true
            end
          end
        end

        UI.error("Could not find #{section_identifier} section in your CHANGELOG.md") if section_content.empty?

        UI.success("Finished reading #{section_identifier} section from '#{changelog_path}'") unless section_content.empty?

        Actions.lane_context[SharedValues::READ_CHANGELOG_SECTION_CONTENT] = section_content
      end

      def self.remove_markdown(line, excluded_markdown_elements)
        markdownless_line = line
        excluded_markdown_elements.each do |element|
          if line =~ /^#{element}/
            markdownless_line = markdownless_line.gsub(element.to_s, "")
          end
        end

        markdownless_line
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Reads content of a section from your project CHANGELOG.md file"
      end

      def self.details
        "This action is inspired by \"Keep a CHANGELOG\" project (see http://keepachangelog.com/). \"Keep a CHANGELOG\" introduces a structed CHANGELOG.md file,
        which contains a curated, chronologically ordered list of notable changes for each version of a project. Use this action to read content of a section
        from your project's CHANGELOG.md."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :changelog_path,
                                       env_name: "FL_READ_CHANGELOG_PATH_TO_CHANGELOG",
                                       description: "The path to your project CHANGELOG.md",
                                       is_string: true,
                                       default_value: "./CHANGELOG.md",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :section_identifier,
                                       env_name: "FL_READ_CHANGELOG_SECTION_IDENTIFIER",
                                       description: "The unique section identifier to read content of",
                                       is_string: true,
                                       default_value: "[Unreleased]",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Sections (##) in CHANGELOG format must be encapsulated in []") unless value.start_with?("[") && value.end_with?("]")
                                         UI.user_error!("Sections (##) in CHANGELOG format cannot be empty") if value[/\[(.*?)\]/, 1].empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :excluded_markdown_elements,
                                       env_name: "FL_READ_CHANGELOG_EXCLUDED_MARKDOWN_ELEMENTS",
                                       description: "Markdown elements you wish to exclude from the output",
                                       type: Array,
                                       default_value: ["###"],
                                       optional: true)
        ]
      end

      def self.output
        [
          ['READ_CHANGELOG_SECTION_CONTENT', 'Contains text from a section of your CHANGELOG.md file']
        ]
      end

      def self.authors
        ["pprochazka72"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
