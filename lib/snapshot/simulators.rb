module Snapshot
  class Simulators
    def self.available_devices
      Helper.log.info "Fetching available devices" if $verbose
      if not @result
        @result = []

        # we do it using open since ` just randomly hangs with instruments -s
        output = ''
        Open3.popen3('instruments -s') do |stdin, stdout, stderr, wait_thr|
          output = stdout.read
        end

        output.split("\n").each do |current|
          # Example: "iPhone 5 (8.1 Simulator) [C49ECC4A-5A3D-44B6-B9BF-4E25BC326400]"
          @result << current.split(' [').first if current.include?"Simulator"
        end
      end
      return @result
    end
  end
end