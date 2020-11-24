require 'fastlane_core/languages'
require 'spaceship/tunes/tunes'

require_relative 'module'
require_relative 'app_screenshot'
require_relative 'upload_metadata'
require_relative 'languages'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze

    SPECIAL_DIR_NAMES = [APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME].freeze

    # Some exception directories may exist from other actions that should not be iterated through
    SUPPLY_DIR_NAME = "android".freeze
    FRAMEIT_FONTS_DIR_NAME = "fonts".freeze
    META_DIR_NAMES = UploadMetadata::ALL_META_SUB_DIRS.map(&:downcase)

    EXCEPTION_DIRECTORIES = (META_DIR_NAMES << SUPPLY_DIR_NAME << FRAMEIT_FONTS_DIR_NAME).freeze

    # A class that represents language folder under screenshots or metadata folder
    class LanguageFolder
      attr_reader :path

      # @return [String] A normalized language name that corresponds to the directory's name
      attr_reader :language

      def self.available_languages
        # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
        # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is avilable)
        Deliver::Languages::ALL_LANGUAGES
      end

      def self.allowed_directory_names_with_case
        available_languages + SPECIAL_DIR_NAMES
      end

      # @param path [String] A directory path otherwise this initializer fails
      # @param nested [Boolan] Whether given path is nested of another special directory.
      #  This affects `expandable?` to return `false` when this set to `true`.
      def initialize(path, nested: false)
        raise(ArgumentError, "Given path must be a directory path - #{path}") unless File.directory?(path)
        @path = path
        @language = self.class.available_languages.find { |lang| basename.casecmp?(lang) }
        @nested = nested
      end

      def nested?
        @nested
      end

      def valid?
        !@language.nil? || expandable?
      end

      def expandable?
        !nested? && SPECIAL_DIR_NAMES.map(&:downcase).include?(basename.downcase)
      end

      def skip?
        EXCEPTION_DIRECTORIES.map(&:downcase).include?(basename.downcase)
      end

      def file_paths(extensions = '{png,jpg,jpeg}')
        Dir.glob(File.join(path, "*.#{extensions}"), File::FNM_CASEFOLD).sort
      end

      def framed_file_paths(extensions = '{png,jpg,jpeg}')
        Dir.glob(File.join(path, "*_framed.#{extensions}"), File::FNM_CASEFOLD).sort
      end

      def basename
        File.basename(@path)
      end
    end

    # Returns the list of valid app screenshot
    #
    # @param root [String] A directory path
    # @param ignore_validation [String] Set false not to raise the error when finding invalid folder name
    # @return [Array<AppScreenshot>] The list of AppScreenshot that exist under given `root` directory
    def self.load_app_screenshots(root, ignore_validation)
      screenshots = language_folders(root, ignore_validation, true).flat_map do |language_folder|
        paths = if language_folder.framed_file_paths.count > 0
                  UI.important("Framed screenshots are detected! 🖼 Non-framed screenshot files may be skipped. 🏃")
                  # watchOS screenshots can be picked up even when framed ones were found since frameit doesn't support watchOS screenshots
                  framed_or_watch, skipped = language_folder.file_paths.partition { |path| path.downcase.include?('framed') || path.downcase.include?('watch') }
                  skipped.each { |path| UI.important("🏃 Skipping screenshot file: #{path}") }
                  framed_or_watch
                else
                  language_folder.file_paths
                end
        paths.map { |path| AppScreenshot.new(path, language_folder.language) }
      end

      errors = []
      valid_screenshots = screenshots.select { |screenshot| validate_screenshot(screenshot, errors) }

      unless errors.empty?
        UI.important("Unaccepted device screenshots are detected! 🚫 Screenshot file will be skipped. 🏃")
        errors.each { |error| UI.important(error) }
      end

      valid_screenshots
    end

    # Validate a screenshot and inform an error message via `errors` parameters. `errors` is mutated
    # to append the messages and each message should contain the corresponding path to let users know which file gets the error.
    #
    # @param screenshot [AppScreenshot]
    # @param errors [Array<String>] Pass an array object to add error messages when finding an error
    # @return [Boolean] true if given screenshot is valid
    def self.validate_screenshot(screenshot, errors)
      # Given screenshot will be diagnosed and errors found are accumulated
      errors_found = []

      # Checking if the device type exists in spaceship
      # Ex: iPhone 6.1 inch isn't supported in App Store Connect but need
      # to have it in there for frameit support
      if screenshot.device_type.nil?
        errors_found << "🏃 Skipping screenshot file: #{screenshot.path} - Not an accepted App Store Connect device..."
      end

      # Merge errors found into given errors array
      errors_found.each { |error| errors.push(error) }
      errors_found.empty?
    end

    # Returns the list of language folders
    #
    # @param roort [String] A directory path to get the list of language folders
    # @param ignore_validation [Boolean] Set false not to raise the error when finding invalid folder name
    # @param expand_sub_folders [Boolean] Set true to expand special folders; such as "iMessage" to nested language folders
    # @return [Array<LanguageFolder>] The list of LanguageFolder whose each of them
    def self.language_folders(root, ignore_validation, expand_sub_folders = false)
      folders = Dir.glob(File.join(root, '*'))
                   .select { |path| File.directory?(path) }
                   .map { |path| LanguageFolder.new(path, nested: false) }
                   .reject(&:skip?)

      selected_folders, rejected_folders = folders.partition(&:valid?)

      if !ignore_validation && !rejected_folders.empty?
        rejected_folders = rejected_folders.map(&:basename)
        UI.user_error!("Unsupported directory name(s) for screenshots/metadata in '#{root}': #{rejected_folders.join(', ')}" \
                       "\nValid directory names are: #{LanguageFolder.allowed_directory_names_with_case}" \
                       "\n\nEnable 'ignore_language_directory_validation' to prevent this validation from happening")
      end

      # Expand selected_dirs for the special directories
      if expand_sub_folders
        selected_folders = selected_folders.flat_map do |folder|
          if folder.expandable?
            Dir.glob(File.join(folder.path, '*'))
               .select { |p| File.directory?(p) }
               .map { |p| LanguageFolder.new(p, nested: true) }
               .select(&:valid?)
          else
            folder
          end
        end
      end

      selected_folders
    end
  end
end
