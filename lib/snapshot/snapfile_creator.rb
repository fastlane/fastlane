module Snapshot
  class SnapfileCreator
    # This method will take care of creating a Snapfile
    def self.create(path)
      path = [path, 'Snapfile'].join("/")

      raise "Snapfile already exists at path '#{path}'. Run 'snapshot' to use Snapshot.".red if File.exists?(path)

      template = File.read("#{gem_path}/lib/assets/SnapfileTemplate")
      File.write(path, template)

      puts "Successfully created new Snapfile at '#{path}'".green
    end

     private
      def self.gem_path
        if not Helper.is_test? and Gem::Specification::find_all_by_name('snapshot').any?
          return Gem::Specification.find_by_name('snapshot').gem_dir
        else
          return './'
        end
      end
  end
end