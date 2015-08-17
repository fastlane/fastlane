require 'open3'

module Snapshot
  class Simulators
    # @return the raw value of the `instruments -s` command
    # we do it using `open3` since only ` just randomly hangs with instruments -s
    def self.raw_simulators
      return @result if @result

      Open3.popen3('instruments -s') do |stdin, stdout, stderr, wait_thr|
        @result = stdout.read
      end
      
      @result || ''
    end

    def self.available_devices(name_only = false)
      Helper.log.info "Fetching available devices" if $verbose
      result = []
      
      output = self.raw_simulators

      output.split("\n").each do |current|
        # Example: "iPhone 5 (8.1 Simulator) [C49ECC4A-5A3D-44B6-B9BF-4E25BC326400]"
        if name_only
          result << current.split(' (').first if current.include?"Simulator"
        else
          result << current.split(' [').first if current.include?"Simulator"
        end
      end

      return result
    end
  end
end