module Deliver
  class HtmlGenerator
    # Renders all data available in the Deliverer to quickly see if everything was correctly generated.
    # @param deliverer [Deliver::Deliverer] The deliver process on which based the HTML file should be generated
    # @param export_path (String) The path to a folder where the resulting HTML file should be stored. 
    def render(deliverer, export_path = nil)
      lib_path = Helper.gem_path('deliver')
      
      @data = deliverer.app.metadata.information

      html_path = File.join(lib_path, "lib/assets/summary.html.erb")
      html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      export_path ||= ENV["DELIVER_HTML_EXPORT_PATH"] || '.' # DELIVER_HTML_EXPORT_PATH used in tests to use /tmp
      export_path = File.join(export_path, "Preview.html")
      File.write(export_path, html)

      return export_path
    end
  end
end