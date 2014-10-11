module IosDeployKit

  class ItunesTransporter
    
    def self.set_mock_file(file_name)
      raise "File #{file_name} not found" unless File.exists?file_name
      @@mocking_file = file_name
    end

    private
      def execute_transporter(command)
        raise "You have to set a mock file for this test!" unless defined?@@mocking_file and @@mocking_file

        @errors = []
        @warnings = []

        File.readlines(@@mocking_file).each do |line|
          parse_line(line)
        end

        if @errors.count > 0
          Helper.log.debug(caller)
          raise TransporterTransferError.new(@errors.join("\n"))
        end

        if @warnings.count > 0
          Helper.log.warn(@warnings.join("\n"))
        end

        @@mocking_file = nil # clear it afterwards

        true
      end

  end
end