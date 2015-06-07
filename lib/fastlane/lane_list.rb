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
      
      all_keys = ff.runner.description_blocks.keys.reject(&:nil?) 
      all_keys.unshift(nil) # because we want root elements on top. always! They have key nil

      all_keys.each do |platform|
        next if (ff.runner.description_blocks[platform] || []).count == 0
        plat_text = platform
        plat_text = "general" if platform.to_s.empty?
        output += "\n--------- #{plat_text}---------\n".yellow
      
        value = ff.runner.description_blocks[platform]
        
        if value
          value.each do |lane, description|
            lane_text = "----- fastlane "
            lane_text += platform.to_s + " " if platform
            lane_text += lane.to_s + "\n"

            output += lane_text.green
            output += description.gsub("\n\n", "\n") + "\n\n" if description.to_s.length > 0
          end
        end
      end

      output
    end
  end
end