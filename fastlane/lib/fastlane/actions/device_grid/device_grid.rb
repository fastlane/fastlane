# rubocop:disable Style/IndentationConsistency
# We disable this rule since we intend opening HTML labels
module Danger
  class Dangerfile
    module DSL
      # A danger plugin: https://github.com/danger/danger
      class DeviceGrid < Plugin
        # @param public_key: The key for the Appetize.io
        # @param languages: Array of languages you want to see (e.g. [en, de])
        # @param devices: Array of deviecs you want to see (e.g. ["iphone4s", "ipadair"])
        # @param prefix_command: Prefix the `fastlane run appetize_viewing_url_generator` command with something
        #   this can be used to use `bundle exec`
        def run(public_key: nil, languages: nil, devices: nil, prefix_command: nil)
          # since we fetch the URL from the output we don't need colors
          # this will only be changed in the danger sub-process
          fastlane_colors_env = "FASTLANE_DISABLE_COLORS"
          fastlane_colors_were_disabled = ENV.key?(fastlane_colors_env)
          ENV[fastlane_colors_env] = "true"

          devices ||= %w(iphone4s iphone5s iphone6s iphone6splus ipadair)
          languages ||= ["en"]
          prefix_command = "bundle exec" if File.exist?("Gemfile")
          prefix_command ||= ""

          deep_link_matches = pr_body.match(/:link:\s(.*)/) # :link: emoji
          deep_link = deep_link_matches[1] if deep_link_matches

          markdown("<table>")
          languages.each do |current_language|
            markdown("<tr>")
              markdown("<td>")
                markdown("<b>#{current_language[0..1]}</b>")
              markdown("</td>")

              devices.each do |current_device|
                markdown("<td>")

                params = {
                  public_key: public_key,
                  language: current_language,
                  device: current_device
                }
                params[:launch_url] = deep_link if deep_link
                params_str = params.collect { |k, v| "#{k}:\"#{v}\"" }.join(" ")
                url = `#{prefix_command} fastlane run appetize_viewing_url_generator #{params_str}`
                url = url.match(%r{Result:.*(https\:\/\/.*)})[1].strip

                markdown("<a href='#{url}'>")
                  markdown("<p align='center'>")
                    markdown("<img height='130' src='#{url_for_device(current_device)}' />")
                    markdown("<br />")
                    markdown(beautiful_device_name(current_device))
                  markdown("</p>")
                markdown("</a>")

                markdown("</td>")
              end
            markdown("</tr>")
          end
          markdown("</table>")
        ensure
          ENV.delete(fastlane_colors_env) unless fastlane_colors_were_disabled
        end

        def beautiful_device_name(str)
          return {
            iphone4s: "iPhone 4s",
            iphone5s: "iPhone 5s",
            iphone6s: "iPhone 6s",
            iphone6splus: "iPhone 6s Plus",
            ipadair: "iPad Air",
            iphone6: "iPhone 6",
            iphone6plus: "iPhone 6 Plus",
            ipadair2: "iPad Air 2",
            nexus5: "Nexus 5",
            nexus7: "Nexus 7",
            nexus9: "Nexus 9"
          }[str.to_sym] || str.to_s
        end

        def url_for_device(str)
          str = str.to_sym
          host = "https://raw.githubusercontent.com/fastlane/fastlane/#{Fastlane::VERSION}/fastlane/lib/fastlane/actions/device_grid/assets/"
          return {
            iphone4s: host + "iphone4s.png",
            iphone5s: host + "iphone5s.png",
            iphone6: host + "iphone6s.png",
            iphone6s: host + "iphone6s.png",
            iphone6plus: host + "iphone6splus.png",
            iphone6splus: host + "iphone6splus.png",
            ipadair: host + "ipadair.png",
            ipadair2: host + "ipadair.png"
          }[str] || ""
        end

        def self.description
          [
            "Render a grid of devices"
          ].join(" ")
        end
      end
    end
  end
end
# rubocop:enable Style/IndentationConsistency
