module Deliver

  class ItunesTransporter
    
    def self.set_mock_file(file_name)
      raise "File #{file_name} not found" unless File.exists?file_name
      @@mocking_file = [] unless defined?@@mocking_file
      @@mocking_file << file_name
    end

    def self.clear_mock_files
      @@mocking_file = []
    end

    private
      def execute_transporter(command)
        current = @@mocking_file.shift if defined?@@mocking_file and @@mocking_file
        raise "You have to set a mock file for this test!" unless defined?current and current

        @errors = []
        @warnings = []

        File.readlines(current).each do |line|
          parse_line(line)
        end

        if @errors.count > 0
          Helper.log.debug(caller)
          raise TransporterTransferError.new(@errors.join("\n"))
        end

        if @warnings.count > 0
          Helper.log.warn(@warnings.join("\n"))
        end

        true
      end

  end
end