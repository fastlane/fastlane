module Snapshot
  class SimulatorLauncherConfiguration
    # both
    attr_accessor :languages
    attr_accessor :devices
    attr_accessor :add_photos
    attr_accessor :add_videos
    attr_accessor :clean
    attr_accessor :erase_simulator
    attr_accessor :localize_simulator
    attr_accessor :reinstall_app
    attr_accessor :app_identifier

    # xcode 8
    attr_accessor :number_of_retries
    attr_accessor :stop_after_first_error
    attr_accessor :output_simulator_logs

    # runner
    attr_accessor :launch_args_set
    attr_accessor :output_directory

    # xcode 9
    attr_accessor :concurrent_simulators
    alias concurrent_simulators? concurrent_simulators

    def initialize(snapshot_config: nil)
      @languages = snapshot_config[:languages]
      @devices = snapshot_config[:devices]
      @add_photos = snapshot_config[:add_photos]
      @add_videos = snapshot_config[:add_videos]
      @clean = snapshot_config[:clean]
      @erase_simulator = snapshot_config[:erase_simulator]
      @localize_simulator = snapshot_config[:localize_simulator]
      @reinstall_app = snapshot_config[:reinstall_app]
      @app_identifier = snapshot_config[:app_identifier]
      @number_of_retries = snapshot_config[:number_of_retries]
      @stop_after_first_error = snapshot_config[:stop_after_first_error]
      @output_simulator_logs = snapshot_config[:output_simulator_logs]
      @output_directory = snapshot_config[:output_directory]
      @concurrent_simulators = snapshot_config[:concurrent_simulators]

      launch_arguments = Array(snapshot_config[:launch_arguments])
      # if more than 1 set of arguments, use a tuple with an index
      if launch_arguments.count == 1
        @launch_args_set = [launch_arguments]
      else
        @launch_args_set = launch_arguments.map.with_index { |e, i| [i, e] }
      end
    end
  end
end
