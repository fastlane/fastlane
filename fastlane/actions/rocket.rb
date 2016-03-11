module Fastlane
  module Actions
    class RocketAction < Action
      def self.run(params)
        puts "
        ____
       /    \\
      |      |
      |      |
      |      |
       \\____/
       |    |
       |    |
       |    |
       |____|
      {|    |}
       |    |
       |    |
       | F  |
       | A  |
       | S  |
       | T  |
       | L  |
       | A  |
      /| N  |\\
      || E  ||
      ||    ||
      \\|____|/
       /_\\/_\\
       ######
      ########
       ######
        ####
        ####
         ##
         ##
         ##
         ##
         "
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Outputs ascii-art for a rocket 🚀"
      end

      def self.available_options
        [
        ]
      end

      def self.authors
        ["JaviSoto", "radex"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
