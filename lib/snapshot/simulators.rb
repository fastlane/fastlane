module Snapshot
  class Simulators
    def self.available_devices
      if not @result
        @result = []
        `instruments -s`.split("\n").each do |current|
          # Example: "iPhone 5 (8.1 Simulator) [C49ECC4A-5A3D-44B6-B9BF-4E25BC326400]"
          @result << current.split(' [').first if current.include?"Simulator"
        end
      end
      return @result
    end
  end
end