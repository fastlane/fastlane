require 'fastlane'
require 'fastlane_core'
require 'spaceship'
require 'terminal-table'
require 'review/rule_processor'

module Review
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to download app metadata and then run all rule checkers
    def run
      FastlaneCore::PrintTable.print_values(config: Review.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for review #{Fastlane::VERSION}")
      UI.message "Starting login with user '#{Review.config[:username]}'"
      Spaceship::Tunes.login(Review.config[:username])
      Spaceship::Tunes.select_team

      UI.message "Successfully logged in"

      ensure_app_exists!

      processor_result = check_for_rule_violations(app_version: latest_app_version)
      build_console_output(processor_result: processor_result)
    end

    def build_console_output(processor_result: nil)
      results_table = build_results_table(results: processor_result.rule_check_results)
      puts results_table

      if processor_result.items_not_checked.length > 0
        items_not_checked_table = build_items_not_checked_table(items_not_checked: processor_result.items_not_checked)
        puts items_not_checked_table
        FastlaneCore::UI.message "The above items were skipped because enough rules were disabled that the items weren't checked by any rules."
      end
    end

    def check_for_rule_violations(app_version: nil)
      Review::RuleProcessor.process_app_version(app_version: app_version, rules: Review::Options.rules)
    end

    def build_results_table(results: nil)
      rules = results.flat_map(&:rule)

      # all rules that were run
      rules.uniq!

      failed_results = []

      # store one copy of each skipped rule because we're only reporting it once, not every time we skipped
      skipped_rules = Set.new

      results.each do |result|
        if result.status == VALIDATION_STATES[:fail]
          failed_results << result
        elsif result.status == VALIDATION_STATES[:skipped]
          skipped_rules.add(result.rule)
        end
      end

      env_output = "\n"
      env_output << rendered_rules_checked_table(rules_checked: rules)
      env_output << "\n"

      rendered_skipped_rules_table = rendered_skipped_rules_table(skipped_rules: skipped_rules)
      unless rendered_skipped_rules_table.nil?
        env_output << rendered_skipped_rules_table
        env_output << "\n"
      end

      env_output << rendered_failed_results_table(failed_results: failed_results)
      env_output << "\n"
      return env_output
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
        title: "Skipped Rules".yellow,
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
        title: "Not Analyzed".yellow,
        headings: ["Name", "Friendly Name"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      ).to_s
    end

    def app
      Spaceship::Tunes::Application.find(Review.config[:app_identifier])
    end

    def latest_app_version
      app.latest_version
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if app
      UI.user_error!("Could not find App with App Identifier '#{Review.config[:app_identifier]}'")
    end
  end
end
