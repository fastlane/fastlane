require 'snapshot/helper'

module Snapshot
  class SnapfileCreator
    # This method will take care of creating a Snapfile
    def self.create(path)
      snapfile_path = File.join(path, 'Snapfile')

      raise "Snapfile already exists at path '#{snapfile_path}'. Run 'snapshot' to use Snapshot.".red if File.exists?(snapfile_path)

      File.write(snapfile_path, File.read("#{gem_path}/lib/assets/SnapfileTemplate"))
      File.write([path, 'snapshot.js'].join('/'), File.read("#{gem_path}/lib/assets/snapshot.js"))
      File.write([path, 'SnapshotHelper.js'].join('/'), File.read("#{gem_path}/lib/assets/SnapshotHelper.js"))

      puts "Successfully created SnapshotHelper.js '#{[path, 'SnapshotHelper.js'].join('/')}'".green
      puts "Successfully created new UI Automation JS file at '#{[path, 'snapshot.js'].join('/')}'".green
      puts "Successfully created new Snapfile at '#{snapfile_path}'".green
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