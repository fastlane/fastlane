module Deliver
  class HtmlGenerator
    # Renders all data available to quickly see if everything was correctly generated.
    # @param export_path (String) The path to a folder where the resulting HTML file should be stored. 
    def render(options, screenshots, export_path = nil)
      lib_path = Helper.gem_path('deliver')

      @app = options[:app]
      @version = @app.latest_version
      @screenshots = screenshots || []

      # html_path = File.join(lib_path, "lib/assets/summary.html.erb")
      html_path = "./lib/assets/summary.html.erb"
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path = File.join(export_path, "Preview.html")
      File.write(export_path, html)

      return export_path
    end
  end
end