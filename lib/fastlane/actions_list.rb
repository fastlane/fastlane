module Fastlane
  class ActionsList
    def self.run(filter)
      require 'terminal-table'
      print_all unless filter
      show_details(filter) if filter
    end

    def self.print_all
      rows = []
      all_actions do |action, name|
        current = []
        current << name.yellow

        if action < Action
          current << action.description if action.description
          current << action.author.green if action.author
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

      puts "Get more information for one specific action using `fastlane action [name]`"
    end

    def self.show_details(filter)
      puts "Loading documentation for #{filter}:".green

      puts ""

      all_actions do |action, name|
        next unless name == filter.strip
        
        rows = []
        rows << [action.description] if action.description
        rows << [' ']
        rows << ["Created by #{action.author.green}"] if action.description

        puts Terminal::Table.new(
          title: filter.green,
          rows: rows
        )

        puts "\n"

        rows = parse_options(action.available_options) if action.available_options

        if rows
          table = Terminal::Table.new(
            title: filter.green,
            headings: ['Key', 'Description', 'Environment Variable'],
            rows: rows
          )
          puts table
        else
          puts "No available options"
        end

        puts "More information can be found on https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md"
        puts "\n"

        return # our job is done here
      end

      puts "Couldn't find action for the given filter.".red
      puts "==========================================\n".red
      print_all # show all available actions instead
    end


    private
      # Iterates through all available actions and yields from there
      def self.all_actions
        all_actions = Fastlane::Actions.constants.select {|c| Class === Fastlane::Actions.const_get(c)}
        all_actions.each do |symbol|        
          action = Fastlane::Actions.const_get(symbol)
          name = symbol.to_s.gsub('Action', '').fastlane_underscore
          yield action, name
        end
      end

      def self.parse_options(options)
        rows = []
        rows << [options] if options.kind_of?String

        if options.kind_of?Array
          options.each do |current|
            if current.kind_of?FastlaneCore::ConfigItem
              rows << [current.key.to_s.yellow, current.description, current.env_name]
            elsif current.kind_of?Array
              raise "Invalid number of elements in this row: #{current}. Must be 2 or 3".red unless ([2, 3].include?current.count)
              rows << current
              rows.last[0] = rows.last.first.yellow # color it yellow :) 
              rows.last << nil if rows.last.count == 2 # to have a nice border in the table
            end
          end
        end

        rows
      end
  end
end