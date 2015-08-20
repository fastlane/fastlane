module Gym
  class Manager
    def work(options)
      Gym.config = options

      print_summary

      return Runner.new.run
    end

    private

    def print_summary
      config = Gym.config
      rows = []
      rows << ["Project", config[:project]] if config[:project]
      rows << ["Workspace", config[:workspace]] if config[:workspace]
      rows << ["Scheme", config[:scheme]] if config[:scheme]
      rows << ["Configuration", config[:configuration]] if config[:configuration]
      rows << ["Platform", Gym.project.ios? ? "iOS" : "Mac"]
      rows << ["Xcode Path", Gym.xcode_path.gsub("/Contents/Developer", "")]

      puts ""
      puts Terminal::Table.new(
        title: "Building Application 🚀".green,
        rows: rows
      )
      puts ""
    end
  end
end
