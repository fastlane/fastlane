require 'terminal-table'
require 'fastlane_core/print_table'
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/application'

require_relative 'rule_processor'
require_relative 'options'

module Precheck
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to download app metadata and then run all rule checkers
    def run
      Precheck.config.load_configuration_file(Precheck.precheckfile_name)

      FastlaneCore::PrintTable.print_values(config: Precheck.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for precheck #{Fastlane::VERSION}")

      unless Spaceship::Tunes.client
        UI.message("Starting login with user '#{Precheck.config[:username]}'")
        Spaceship::Tunes.login(Precheck.config[:username])
        Spaceship::Tunes.select_team

        UI.message("Successfully logged in")
      end

      UI.message("Checking app for precheck rule violations")

      ensure_app_exists!

      processor_result = check_for_rule_violations(app: app, app_version: latest_app_version)

      if processor_result.items_not_checked?
        print_items_not_checked(processor_result: processor_result)
      end

      if processor_result.has_errors_or_warnings?
        summary_table = build_potential_problems_table(processor_result: processor_result)
        puts(summary_table)
      end

      if processor_result.should_trigger_user_error?
        UI.user_error!("precheck 👮‍♀️ 👮  found one or more potential problems that must be addressed before submitting to review")
        return false
      end

      if processor_result.has_errors_or_warnings?
        UI.important("precheck 👮‍♀️ 👮  found one or more potential metadata problems, but this won't prevent fastlane from completing 👍".yellow)
      end

      if !processor_result.has_errors_or_warnings? && !processor_result.items_not_checked?
        UI.message("precheck 👮‍♀️ 👮  finished without detecting any potential problems 🛫".green)
      end

      return true
    end

    def print_items_not_checked(processor_result: nil)
      names = processor_result.items_not_checked.map(&:friendly_name)
      UI.message("😶  Metadata fields not checked by any rule: #{names.join(', ')}".yellow) if names.length > 0
    end

    def build_potential_problems_table(processor_result: nil)
      error_results = processor_result.error_results
      warning_results = processor_result.warning_results

      rows = []

      warning_results.each do |rule, results|
        results.each do |result|
          rows << [result.item.friendly_name, result.rule_return.failure_data.yellow]
        end
      end

      error_results.each do |rule, results|
        results.each do |result|
          rows << [result.item.friendly_name, result.rule_return.failure_data.red]
        end
      end

      if rows.length == 0
        return nil
      else
        title_text = "Potential problems"
        if error_results.length > 0
          title_text = title_text.red
        else
          title_text = title_text.yellow
        end
        return Terminal::Table.new(
          title: title_text,
          headings: ["Field", "Failure reason"],
          rows: FastlaneCore::PrintTable.transform_output(rows)
        ).to_s
      end
    end

    def check_for_rule_violations(app: nil, app_version: nil)
      Precheck::RuleProcessor.process_app_and_version(
        app: app,
        app_version: app_version,
        rules: Precheck::Options.rules
      )
    end

    def rendered_failed_results_table(failed_results: nil)
      rows = []
      failed_results.each do |failed_result|
        rows << [failed_result.rule.key, failed_result.item.friendly_name]
      end

      return Terminal::Table.new(
        title: "Failed rules".red,
        headings: ["Name", "App metadata field: (language code)"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      ).to_s
    end

    def rendered_rules_checked_table(rules_checked: nil)
      rows = []
      rules_checked.each do |rule|
        rows << [rule.key, rule.description]
      end

      return Terminal::Table.new(
        title: "Enabled rules".green,
        headings: ["Name", "Description"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      ).to_s
    end

    def rendered_skipped_rules_table(skipped_rules: nil)
      return nil if skipped_rules.empty?

      rows = []
      skipped_rules.each do |rule|
        rows << [rule.key, rule.description]
      end

      return Terminal::Table.new(
        title: "Skipped rules".yellow,
        headings: ["Name", "Description"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      ).to_s
    end

    def build_items_not_checked_table(items_not_checked: nil)
      rows = []
      items_not_checked.each do |item|
        rows << [item.item_name, item.friendly_name]
      end

      return Terminal::Table.new(
        title: "Not analyzed".yellow,
        headings: ["Name", "Friendly name"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      ).to_s
    end

    def app
      Spaceship::Tunes::Application.find(Precheck.config[:app_identifier])
    end

    def latest_app_version
      @latest_version ||= app.latest_version
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if app
      UI.user_error!("Could not find app with App Identifier '#{Precheck.config[:app_identifier]}'")
    end
  end
end
