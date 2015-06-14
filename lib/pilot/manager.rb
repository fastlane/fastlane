module Pilot
  class Manager
    def run(options)
      package_path = PackageBuilder.new.generate(apple_id: 999017138, 
                                                 ipa_path: options[:ipa],
                                             package_path: "/tmp")
      package_path
    end
  end
end