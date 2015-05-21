module Fastlane
  module Actions
    module SharedValues
      TRELLO_WHAT_TO_TEST = :TRELLO_WHAT_TO_TEST      
    end

    class TrelloAction < Action
      
      def self.run(params)

        require 'trello'
        require 'shellwords'
        
        Trello.configure do |config|
          config.developer_public_key = params[:public_key]
          config.member_token = params[:member_token]
        end
  
        folder = '.' #subfolder folder is the default folder

        command_prefix = [
            'cd',
            File.expand_path(folder).shellescape,
            '&&'
        ].join(' ')

        begin
#          Actions.lane_context[SharedValues::WHAT_TO_TEST] = ""
          current_version = `#{command_prefix} agvtool what-marketing-version -terse1`.split("\n").last || ''
          build_number = `#{command_prefix} agvtool what-version`.split("\n").last.to_i
          title = "Version #{current_version} (#{build_number})"

          board = Trello::Board.find(params[:board_source]) 
  
          list = board.lists.select{ |l| l.name == 'Done'}.first

          if params[:board_target]
            versionBoard = Trello::Board.find(params[:board_target]) 
            newList = Trello::List.create(
              :name => title, 
              :board_id => versionBoard.id
            ) 
          else
            newList = nil
          end

          changes = ""
          cards = list.cards
          cards.each do |card|
            changes = changes + "- " + card.name + "\n"  
            if newList
              card.move_to_board(versionBoard, newList)
              card.save
            end
          end
          changes.chomp!

          ENV[":TRELLO_WHAT_TO_TEST"] = changes    
          Actions.lane_context[SharedValues::TRELLO_WHAT_TO_TEST] = changes    
          Helper.log.info "Successfully generated TRELLO_WHAT_TO_TEST: #{changes}".green
          
        rescue => ex
          Helper.log.fatal ex
          raise "Trello action failed!".red          
        end
      end
            
      def self.description
        "Enumerate trello card titles for changelogs"
      end


      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :public_key,
                                       env_name: "FL_TRELLO_PUBLIC_KEY", 
                                       description: "Public API Key for Trello", 
                                       verify_block: Proc.new do |value|
                                          raise "No API key for Trello cction given, pass using `public_key: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :member_token,
                                       env_name: "FL_TRELLO_MEMBER_TOKEN", 
                                       description: "Member Token for Trello", # 
                                       verify_block: Proc.new do |value|
                                          raise "No member token for Trello action given, pass using `member_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :board_source,
                                       env_name: "FL_TRELLO_BOARD_SOURCE",
                                       description: "ID of trello source board",
                                       optional: false,
                                       is_string: true,
                                       verify_block: Proc.new do |value|
                                          raise "No trello board source id given, pass using `:board_source: 'boardid'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :board_target,
                                       env_name: "TRELLO_BOARD_TARGET",
                                       description: "ID of trello target board",
                                       optional: true,
                                       is_string: true,
                                       default_value: nil)
        ]
      end

      def self.output
        [
          ['TRELLO_WHAT_TO_TEST', 'List of all done-items in Board']
        ]
      end

      def self.author
        "ldrr"
      end
      
      def self.is_supported?(platform)
        true
      end
            
    end
  end
end