# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Fastlane
  class ActionsList
    def self.run(filter: nil, platform: nil)
      require 'terminal-table'
      if filter
        show_details(filter: filter)
      else
        print_all(platform: platform)
      end
    end

    def self.print_all(platform: nil)
      rows = []
      all_actions(platform) do |action, name|
        current = []
        current << name.yellow

        if action < Action
          current << action.description if action.description

          authors = Array(action.author || action.authors)
          current << authors.first.green if authors.count == 1
          current << "Multiple".green if authors.count > 1
        else
          Helper.log.error "Please update your action file #{name} to be a subclass of `Action` by adding ` < Action` after your class name.".red
          current << "Please update action file".red
        end
        rows << current
      end

      table = Terminal::Table.new(
        title: "Available fastlane actions".green,
        headings: ['Action', 'Description', 'Author'],
        rows: rows
      )
      puts table
      puts "  Platform filter: #{platform}".magenta if platform
      puts "  Total of #{rows.count} actions"

      puts "\nGet more information for one specific action using `fastlane action [name]`\n".green
    end

    def self.show_details(filter: nil)
      puts "Loading documentation for #{filter}:".green

      puts ""

      all_actions do |action, name|
        next unless name == filter.strip

        rows = []
        rows << [action.description] if action.description
        rows << [' ']
        if action.details
          rows << [action.details]
          rows << [' ']
        end

        authors = Array(action.author || action.authors)

        rows << ["Created by #{authors.join(', ').green}"] if authors.count > 0

        puts Terminal::Table.new(
          title: filter.green,
          rows: rows
        )

        puts "\n"

        options = parse_options(action.available_options) if action.available_options

        if options
          puts Terminal::Table.new(
            title: filter.green,
            headings: ['Key', 'Description', 'Env Var'],
            rows: options
          )
          required_count = action.available_options.count do |o|
            if o.kind_of?(FastlaneCore::ConfigItem)
              o.optional == false
            else
              false
            end
          end

          if required_count > 0
            puts "#{required_count} of the available parameters are required".magenta
            puts "They are marked with an asterisk *".magenta
          end
        else
          puts "No available options".yellow
        end
        puts "\n"

        output = parse_options(action.output, false) if action.output
        if output and output.count > 0
          puts Terminal::Table.new(
            title: [filter, "| Output Variables"].join(" ").green,
            headings: ['Key', 'Description'],
            rows: output
          )
          puts "Access the output values using `lane_context[SharedValues::VARIABLE_NAME]`"
          puts ""
        end

        if action.return_value
          puts Terminal::Table.new(
            title: "Return Value".green,
            headings: [],
            rows: [[action.return_value]]
          )
          puts ""
        end

        puts "More information can be found on https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md"
        puts "\n"

        return # our job is done here
      end

      puts "Couldn't find action for the given filter.".red
      puts "==========================================\n".red
      print_all # show all available actions instead
    end

    # Iterates through all available actions and yields from there
    def self.all_actions(platform = nil)
      all_actions = Fastlane::Actions.constants.select {|c| Fastlane::Actions.const_get(c).kind_of? Class }
      all_actions.sort.each do |symbol|
        action = Fastlane::Actions.const_get(symbol)

        next if platform && !action.is_supported?(platform.to_sym)

        name = symbol.to_s.gsub('Action', '').fastlane_underscore
        yield action, name
      end
    end

    # Helper:
    def self.parse_options(options, fill_all = true)
      rows = []
      rows << [options] if options.kind_of? String

      if options.kind_of? Array
        options.each do |current|
          if current.kind_of? FastlaneCore::ConfigItem
            key_name = (current.optional ? "" : "* ") + current.key.to_s
            description = current.description + (current.default_value ? " (default: '#{current.default_value}')" : "")

            rows << [key_name.yellow, description, current.env_name]

          elsif current.kind_of? Array
            # Legacy actions that don't use the new config manager
            raise "Invalid number of elements in this row: #{current}. Must be 2 or 3".red unless [2, 3].include? current.count
            rows << current
            rows.last[0] = rows.last.first.yellow # color it yellow :)
            rows.last << nil while fill_all and rows.last.count < 3 # to have a nice border in the table
          end
        end
      end

      rows
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
