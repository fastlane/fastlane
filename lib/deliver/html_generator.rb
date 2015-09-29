module Deliver
  class HtmlGenerator
    def run(options, screenshots)
      begin
        html_path = self.render(options, screenshots, '.')
      rescue => ex
        Helper.log.error ex.inspect
        Helper.log.error ex.backtrace.join("\n")
        okay = agree("Could not render HTML preview. Do you still want to continue? (y/n)".red, true)
        return if okay
        raise "Could not render HTML page"
      end
      puts "----------------------------------------------------------------------------"
      puts "Verifying the upload via the HTML file can be disabled by either adding"
      puts "`force true` to your Deliverfile or using `deliver --force`"
      puts "----------------------------------------------------------------------------"

      system("open '#{html_path}'")
      okay = agree("Does the Preview on path '#{html_path}' look okay for you? (blue = updated) (y/n)", true)

      if okay
        puts "HTML file confirmed..." # print this to give feedback to the user immediately
      else
        raise "Did not upload the metadata, because the HTML file was rejected by the user".yellow
      end
    end

    # Renders all data available to quickly see if everything was correctly generated.
    # @param export_path (String) The path to a folder where the resulting HTML file should be stored.
    def render(options, screenshots, export_path = nil)
      lib_path = Helper.gem_path('deliver')

      @screenshots = screenshots || []
      @options = options

      @app_name = (options[:name]['en-US'] || options[:name].values.first) if options[:name]
      @app_name ||= options[:app].name

      @languages = options[:description].keys if options[:description]
      @languages ||= options[:app].latest_version.description.languages

      html_path = File.join(lib_path, "lib/assets/summary.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = File.join(export_path, "Preview.html")
      File.write(export_path, html)

      return export_path
    end
  end
end
