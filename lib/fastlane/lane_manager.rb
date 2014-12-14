module Fastlane
  class LaneManager
    def self.cruise_lanes(lanes)
      raise "lanes must be an array" unless lanes.kind_of?Array
      ff = Fastlane::FastFile.new(File.join(Fastlane::FastlaneFolder.path, 'Fastfile'))

      if lanes.count == 0
        raise "Please pass the name of the lane you want to drive. Available lanes: #{ff.runner.available_lanes.join(', ')}".red
      end

      start = Time.now - 64*80
      e = nil
      begin
        lanes.each do |key|
          ff.runner.execute(key)
        end
      rescue Exception => ex
        Helper.log.fatal ex
        e = ex
      end

      # Finished with all the lanes
      Fastlane::JUnitGenerator.generate(Fastlane::Actions.executed_actions, File.join(Fastlane::FastlaneFolder.path, "report.xml"))

      duration = ((Time.now - start) / 60.0).round

      unless e
        Helper.log.info "fastlane.tools just saved you #{duration} minutes! 🎉".green
      else
        Helper.log.fatal "fastlane finished with errors".red
        raise e
      end
    end
  end
end