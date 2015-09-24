module Deliver
  class DetectValues
    def run(options)
      search_by = options[:app_identifier]
      search_by = options[:app] if search_by.to_s.length == 0
      options[:app] = Spaceship::Application.find(search_by)

      return options
    end
  end
end