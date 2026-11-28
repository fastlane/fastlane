require 'fastimage'

module Deliver
  class AppScreenshotValidator
    # A simple structure that holds error information as well as formatted error messages consistently
    class ValidationError
      # Constants that can be given to `type` param
      INVALID_SCREEN_SIZE = 'Invalid screen size'.freeze
      INVALID_FILE_EXTENSION = 'Invalid file extension'.freeze
      FILE_EXTENSION_MISMATCH = 'File extension mismatches its image format'.freeze

      attr_reader :type, :path, :debug_info

      def initialize(type: nil, path: nil, debug_info: nil)
        @type = type
        @path = path
        @debug_info = debug_info
      end

      def to_s
        "🚫 Error: #{path} - #{type} (#{debug_info})"
      end

      def inspect
        "\"#{type}\""
      end
    end

    # Access each array by symbol returned from FastImage.type
    ALLOWED_SCREENSHOT_FILE_EXTENSION = { png: ['png', 'PNG'], jpeg: ['jpg', 'JPG', 'jpeg', 'JPEG'] }.freeze

    APP_SCREENSHOT_SPEC_URL = 'https://help.apple.com/app-store-connect/#/devd274dd925'.freeze

    # Validate a screenshot and inform an error message via `errors` parameter. `errors` is mutated
    # to append the messages and each message should contain the corresponding path to let users know which file is throwing the error.
    #
    # @param screenshot [AppScreenshot]
    # @param errors [Array<Deliver::AppScreenshotValidator::ValidationError>] Pass an array object to add validation errors when detecting errors.
    #   This will be mutated to add more error objects as validation detects errors.
    # @return [Boolean] true if given screenshot is valid
    def self.validate(screenshot, errors)
      # Given screenshot will be diagnosed and errors found are accumulated
      errors_found = []

      validate_screen_size(screenshot, errors_found)
      validate_file_extension_and_format(screenshot, errors_found)

      # Merge errors found into given errors array
      errors_found.each { |error| errors.push(error) }
      errors_found.empty?
    end

    def self.validate_screen_size(screenshot, errors_found)
      if screenshot.display_type.nil?
        errors_found << ValidationError.new(type: ValidationError::INVALID_SCREEN_SIZE,
                                            path: screenshot.path,
                                            debug_info: "Screenshot size is not supported. Actual size is #{get_formatted_size(screenshot)}. See the specifications to fix #{APP_SCREENSHOT_SPEC_URL}")
      end
    end

    def self.validate_file_extension_and_format(screenshot, errors_found)
      extension = File.extname(screenshot.path).delete('.')
      valid_file_extensions = ALLOWED_SCREENSHOT_FILE_EXTENSION.values.flatten
      is_valid_extension = valid_file_extensions.include?(extension)

      unless is_valid_extension
        errors_found << ValidationError.new(type: ValidationError::INVALID_FILE_EXTENSION,
                                            path: screenshot.path,
                                            debug_info: "Only #{valid_file_extensions.join(', ')} are allowed")
      end

      format = FastImage.type(screenshot.path)
      is_extension_matched = ALLOWED_SCREENSHOT_FILE_EXTENSION[format] &&
                             ALLOWED_SCREENSHOT_FILE_EXTENSION[format].include?(extension)

      # This error only appears when file extension is valid
      if is_valid_extension && !is_extension_matched
        expected_extension = ALLOWED_SCREENSHOT_FILE_EXTENSION[format].first
        expected_filename = File.basename(screenshot.path, File.extname(screenshot.path)) + ".#{expected_extension}"
        errors_found << ValidationError.new(type: ValidationError::FILE_EXTENSION_MISMATCH,
                                            path: screenshot.path,
                                            debug_info: %(Actual format is "#{format}". Rename the filename to "#{expected_filename}".))
      end
    end

    def self.get_formatted_size(screenshot)
      size = FastImage.size(screenshot.path)
      return size.join('x') if size
      nil
    end
  end
end
