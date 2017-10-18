module Deliver
  # Manages the app's availability
  class Availability
    attr_accessor :all_available
    attr_accessor :exclude
    attr_accessor :available

    def initialize(all_available = false, exclude = [], available = [])
      # Instance variables
      @all_available = all_available
      @exclude = exclude
      @available = available
    end

    # returns a single list of enabled territories
    def territories(all_territories)
      if @all_available
        territories = all_territories
      elsif @exclude.count > 0
        # invert the excluded territories to create a list of allowed ones
        territories = (all_territories - @exclude) | (@exclude - all_territories)
      else
        territories = @available
      end

      return territories
    end

    # saves current options to a YAML file
    def save_to_file(file_path)
      file_object = { available: @available,
                      exclude: @exclude,
                      all_available: @all_available }
      File.write(file_path, file_object.to_yaml)
    end

    # validates current options
    def validate
      if @all_available && (@exclude.count > 0 || @available.count > 0)
        UI.important("Availability_all_territories is true and list of territories provided, lists will be ignored.")
      end

      if @exclude.count > 0 && @available.count > 0
        UI.important("Both availbile and exclude lists provided, exlude list will be used only.")
      end
    end

    class << self
      def from_territories(territories, all_territories)
        obj = self.new

        if all_territories.count == territories.count
          # Set all available instead of using a list for smallest file
          obj.all_available = true
        elsif territories.count > (all_territories.count / 2)
          # To keep the list small invert the available territories to create a smaller ignore list
          obj.exclude = (all_territories - territories) | (territories - all_territories)
        else
          obj.available = territories
        end

        return obj
      end

      def from_file(file_path)
        file_obj = YAML.load_file(file_path)
        return self.new(file_obj[:all_available] || false,
                        file_obj[:exclude] || [],
                        file_obj[:available] || [])
      end

      def from_options(options)
        return self.new(options[:availability_all_territories] || false,
                        options[:availability_exclude_territories] || [],
                        options[:availability_territories] || [])
      end

      # downloads the app's current availability from iTunes connect
      def from_itunes_connect(app)
        current_territories = app.availability.territories.map(&:code)
        all_territories = app.client.supported_territories.map(&:code)

        return Availability.from_territories(current_territories, all_territories)
      end
    end
  end
end
