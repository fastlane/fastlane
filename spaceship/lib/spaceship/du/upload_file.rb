require 'fileutils'

require_relative 'utilities'

module Spaceship
  # a wrapper around the concept of file required to make uploads to DU
  class UploadFile
    attr_reader :file_path
    attr_reader :file_name
    attr_reader :file_size
    attr_reader :content_type
    attr_reader :bytes

    class << self
      def from_path(path)
        raise "Image must exists at path: #{path}" unless File.exist?(path)

        # md5 from original. keeping track of md5s allows to skip previously uploaded in deliver
        content_md5 = Spaceship::Utilities.md5digest(path)
        path = remove_alpha_channel(path) if File.extname(path).casecmp('.png').zero?

        content_type = Utilities.content_type(path)
        self.new(
          file_path: path,
          file_name: 'ftl_' + content_md5 + '_' + File.basename(path),
          file_size: File.size(path),
          content_type: content_type,
          bytes: File.read(path)
        )
      end

      # As things like screenshots and app icon shouldn't contain the alpha channel
      # This will copy the image into /tmp to remove the alpha channel there
      # That's done to not edit the original image
      def remove_alpha_channel(original)
        path = "/tmp/#{Digest::MD5.hexdigest(original)}.png"
        FileUtils.copy(original, path)
        if mac? # sips is only available on macOS
          `sips -s format bmp '#{path}' &> /dev/null` # &> /dev/null since there is warning because of the extension
          `sips -s format png '#{path}'`
        end
        return path
      end

      def mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
      end
    end

    private

    def initialize(args)
      args.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end
end
