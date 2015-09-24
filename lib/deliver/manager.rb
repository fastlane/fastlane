module Deliver
  class Manager
    def run(options)
      runner = Runner.new(options)

      runner.upload_metadata unless options[:skip_metadata]
      # runner.upload_binary if options[:ipa]
    end
  end
end