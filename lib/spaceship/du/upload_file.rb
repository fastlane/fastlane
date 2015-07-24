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
        content_type = Utilities.content_type(path)
        self.new(
          file_path: path,
          file_name: File.basename(path),
          file_size: File.size(path),
          content_type: content_type,
          bytes: File.read(path)
        )
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
