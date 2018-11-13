module Fastlane
  class LaneList
    # Print out the result of `generate`
    SWIFT_FUNCTION_REGEX = /\s*func\s*(\w*)\s*\((.*)\)\s*/
    SWIFT_DESC_REGEX = /\s*desc\s*\(\s*"(.*)"\s*\)\s*/
    def self.output(path)
      puts(generate(path))

      puts("Execute using `fastlane [lane_name]`".yellow)
    end

    def self.generate_swift_lanes(path)
      return unless (path || '').length > 0
      UI.user_error!("Could not find Fastfile.swift at path '#{path}'") unless File.exist?(path)
      path = File.expand_path(path)
      lane_content = File.read(path)

      current_lane_name = nil
      lanes_by_name = {}

      lane_content.split("\n").reject(&:empty?).each do |line|
        line.strip!
        if line.start_with?("func") && (current_lane_name = self.lane_name_from_swift_line(potential_lane_line: line))
          lanes_by_name[current_lane_name] = Fastlane::Lane.new(platform: nil, name: current_lane_name.to_sym, description: [])
        elsif line.start_with?("desc")
          lane_description = self.desc_entry_for_swift_lane(named: current_lane_name, potential_desc_line: line)
          unless lane_description
            next
          end

          lanes_by_name[current_lane_name].description = [lane_description]
          current_lane_name = nil
        end
      end
      # "" because that will be interpreted as general platform
      # (we don't detect platform right now)
      return { "" => lanes_by_name }
    end

    def self.desc_entry_for_swift_lane(named: nil, potential_desc_line: nil)
      unless named
        return nil
      end

      desc_match = SWIFT_DESC_REGEX.match(potential_desc_line)
      unless desc_match
        return nil
      end

      return desc_match[1]
    end

    def self.lane_name_from_swift_line(potential_lane_line: nil)
      function_name_match = SWIFT_FUNCTION_REGEX.match(potential_lane_line)
      unless function_name_match
        return nil
      end

      unless function_name_match[1].downcase.end_with?("lane")
        return nil
      end

      return function_name_match[1]
    end

    def self.generate(path)
      lanes = {}
      if FastlaneCore::FastlaneFolder.swift?
        lanes = generate_swift_lanes(path)
      else
        ff = Fastlane::FastFile.new(path)
        lanes = ff.runner.lanes
      end

      output = ""

      all_keys = lanes.keys.reject(&:nil?)
      all_keys.unshift(nil) # because we want root elements on top. always! They have key nil

      all_keys.each do |platform|
        next if (lanes[platform] || []).count == 0

        plat_text = platform
        plat_text = "general" if platform.to_s.empty?
        output += "\n--------- #{plat_text}---------\n".yellow

        value = lanes[platform]
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

    def self.output_json(path)
      puts(JSON.pretty_generate(self.generate_json(path)))
    end

    # Returns a hash
    def self.generate_json(path)
      output = {}
      return output if path.nil?
      ff = Fastlane::FastFile.new(path)

      all_keys = ff.runner.lanes.keys

      all_keys.each do |platform|
        next if (ff.runner.lanes[platform] || []).count == 0

        output[platform] ||= {}

        value = ff.runner.lanes[platform]
        next unless value

        value.each do |lane_name, lane|
          next if lane.is_private

          output[platform][lane_name] = {
            description: lane.description.join("\n")
          }
        end
      end

      return output
    end
  end
end
