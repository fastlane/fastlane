require 'babosa'

module FastlaneCore
  class DeveloperCenter
    # Download a file from the dev center, by using a HTTP client. This will return the content of the file
    def download_file(url)
      Helper.log.info "Downloading profile..."
      host = Capybara.current_session.current_host
      url = [host, url].join('')

      cookie_string = ""
      
      page.driver.cookies.each do |key, cookie|
        cookie_string << "#{cookie.name}=#{cookie.value};" # append all known cookies
      end
      
      data = open(url, {'Cookie' => cookie_string}).read

      raise "Something went wrong when downloading the file from the Dev Center" unless data
      Helper.log.info "Successfully downloaded provisioning profile"
      return data
    end

    def post_ajax(url, data = nil)
      JSON.parse(page.evaluate_script("$.ajax({type: 'POST', url: '#{url}', async: false#{data.nil? ? '' : ", data: #{data}"} })")['responseText'])
    end

    def click_next
      wait_for_elements('.button.small.blue.right.submit').last.click
    end

    def error_occured(ex)
      snap
      raise ex # re-raise the error after saving the snapshot
    end

    def snap
      path = File.expand_path("Error#{Time.now.to_i}.png")
      save_screenshot(path, :full => true)
      system("open '#{path}'") unless ENV['SIGH_DISABLE_OPEN_ERROR']
    end

    def wait_for(method, parameter, success)
      counter = 0
      result = method.call(parameter)
      while !success.call(result)
        sleep 0.2

        result = method.call(parameter)

        counter += 1
        if counter > 100
          Helper.log.debug caller
          raise DeveloperCenterGeneralError.new("Couldn't find '#{parameter}' after waiting for quite some time")
        end
      end
      return result
    end

    def wait_for_elements(name)
      method = Proc.new { |n| all(name) }
      success = Proc.new { |r| r.count > 0 }
      return wait_for(method, name, success)
    end

    def wait_for_variable(name)
      method = Proc.new { |n|
        retval = page.html.match(/var #{n} = "(.*)"/)
        retval[1] unless retval == nil
      }
      success = Proc.new { |r| r != nil }
      return wait_for(method, name, success)
    end

    def valid_name_for(input)
      latinazed = input.to_slug.transliterate.to_s # remove accents
      latinazed.gsub(/[^0-9A-Za-z\d\s]/, '') # remove non-valid characters
    end
  end
end