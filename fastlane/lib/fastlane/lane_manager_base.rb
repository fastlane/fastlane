module Fastlane
  # Base class for all LaneManager classes
  # Takes care of all common things like printing the lane description tables and loading .env files
  class LaneManagerBase
    def self.skip_docs?
      Helper.test? || FastlaneCore::Env.truthy?("FASTLANE_SKIP_DOCS")
    end

    # All the finishing up that needs to be done
    def self.finish_fastlane(ff, duration, error, skip_message: false)
      # Sometimes we don't have a fastfile because we're using Fastfile.swift
      unless ff.nil?
        ff.runner.did_finish
      end

      # Finished with all the lanes
      Fastlane::JUnitGenerator.generate(Fastlane::Actions.executed_actions)
      print_table(Fastlane::Actions.executed_actions)

      Fastlane::PluginUpdateManager.show_update_status

      if error
        UI.error('fastlane finished with errors') unless skip_message
        raise error
      elsif duration > 5
        UI.success("fastlane.tools just saved you #{duration} minutes! 🎉") unless skip_message
      else
        UI.success('fastlane.tools finished successfully 🎉') unless skip_message
      end
    end

    # Print a table as summary of the executed actions
    def self.print_table(actions)
      return if actions.count == 0
      return if FastlaneCore::Env.truthy?('FASTLANE_SKIP_ACTION_SUMMARY') # User disabled table output

      require 'terminal-table'

      rows = []
      actions.each_with_index do |current, i|
        is_error_step = !current[:error].to_s.empty?

        name = current[:name][0..60]
        name = name.red if is_error_step
        index = i + 1
        index = "💥" if is_error_step
        rows << [index, name, current[:time].to_i]
      end

      puts("")
      puts(Terminal::Table.new(
             title: "fastlane summary".green,
             headings: ["Step", "Action", "Time (in s)"],
             rows: FastlaneCore::PrintTable.transform_output(rows)
      ))
      puts("")
    end

    def self.print_lane_context
      return if Actions.lane_context.empty?

      if FastlaneCore::Globals.verbose?
        UI.important('Lane Context:'.yellow)
        UI.message(Actions.lane_context)
        return
      end

      # Print a nice table unless in FastlaneCore::Globals.verbose? mode
      rows = Actions.lane_context.collect do |key, content|
        [key, content.to_s]
      end

      require 'terminal-table'
      puts(Terminal::Table.new({
        title: "Lane Context".yellow,
        rows: FastlaneCore::PrintTable.transform_output(rows)
      }))
    end

    def self.print_error_line(ex)
      lines = ex.backtrace_locations&.select { |loc| loc.path == 'Fastfile' }&.map(&:lineno)
      return if lines.nil? || lines.empty?

      fastfile_content = File.read(FastlaneCore::FastlaneFolder.fastfile_path, encoding: "utf-8")
      if ex.backtrace_locations.first&.path == 'Fastfile'
        # If exception happened directly in the Fastfile itself (e.g. ArgumentError)
        UI.error("Error in your Fastfile at line #{lines.first}")
        UI.content_error(fastfile_content, lines.first)
        lines.shift
      end

      unless lines.empty?
        # If exception happened directly in the Fastfile, also print the caller (still from the Fastfile).
        # If exception happened in _fastlane_ internal code, print the line from the Fastfile that called it
        UI.error("Called from Fastfile at line #{lines.first}")
        UI.content_error(fastfile_content, lines.first)
      end
    end
  end
end
