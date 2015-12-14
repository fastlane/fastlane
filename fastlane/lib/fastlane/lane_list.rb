module Fastlane
  class LaneList
    # Print out the result of `generate`
    def self.output(path)
      puts generate(path)

      puts "Execute using `fastlane [lane_name]`".yellow
    end

    def self.generate(path)
      ff = Fastlane::FastFile.new(path)
      output = ""

      all_keys = ff.runner.lanes.keys.reject(&:nil?)
      all_keys.unshift(nil) # because we want root elements on top. always! They have key nil

      all_keys.each do |platform|
        next if (ff.runner.lanes[platform] || []).count == 0

        plat_text = platform
        plat_text = "general" if platform.to_s.empty?
        output += "\n--------- #{plat_text}---------\n".yellow

        value = ff.runner.lanes[platform]
        next unless value

        value.each do |lane_name, lane|
          next if lane.is_private

          output += "----- fastlane #{lane.pretty_name}".green
          if lane.description.count > 0
            output += "\n" + lane.description.join("\n") + "\n\n"
          else
            output += "\n\n"
          end
        end
      end

      output
    end
  end
end
