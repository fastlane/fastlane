module Raven
  # This class gets rid of the user folder, as we don't want to share the username
  class Processor
    class CleanStackTrace < Processor
      def process(value)
        if value[:exception]
          value[:exception][:values].each do |single_exception|
            single_exception[:stacktrace][:frames].each do |current|
              current[:abs_path].gsub!(Dir.home, "~")
            end
          end
        end

        return value
      end
    end
  end
end
