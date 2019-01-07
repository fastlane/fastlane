require 'fileutils'
require 'tmpdir'

describe Fastlane::Actions do
  describe '#xcodeproj_helper' do
    PATH = 'Project.xcodeproj'.freeze
    SECONDARY_PATH = 'Secondary/Project.xcodeproj'.freeze
    COCOAPODS_PATH = 'Pods/Pod.xcodeproj'.freeze
    COCOAPODS_FRAMEWORK_EXAMPLE_PATH = 'Pods/Alamofire/Example/iOS Example.xcodeproj'.freeze
    CARTHAGE_FRAMEWORK_PATH = 'Carthage/Checkouts/Alamofire/Alamofire.xcodeproj'.freeze
    CARTHAGE_FRAMEWORK_EXAMPLE_PATH = 'Carthage/Checkouts/Alamofire/Example iOS Example.xcodeproj'.freeze

    let(:dir) { Dir.mktmpdir }

    it 'finds one' do
      path = File.join(dir, PATH)
      FileUtils.mkdir_p(path)

      paths = Fastlane::Helper::XcodeprojHelper.find(dir)
      expect(paths).to contain_exactly(path)
    end

    it 'finds multiple nested' do
      path = File.join(dir, PATH)
      FileUtils.mkdir_p(path)

      secondary_path = File.join(dir, SECONDARY_PATH)
      FileUtils.mkdir_p(secondary_path)

      paths = Fastlane::Helper::XcodeprojHelper.find(dir)
      expect(paths).to contain_exactly(path, secondary_path)
    end

    it 'finds multiple nested, ignoring dependencies' do
      path = File.join(dir, PATH)
      FileUtils.mkdir_p(path)

      secondary_path = File.join(dir, SECONDARY_PATH)
      FileUtils.mkdir_p(secondary_path)

      FileUtils.mkdir_p(File.join(dir, COCOAPODS_PATH))
      FileUtils.mkdir_p(File.join(dir, COCOAPODS_FRAMEWORK_EXAMPLE_PATH))
      FileUtils.mkdir_p(File.join(dir, CARTHAGE_FRAMEWORK_PATH))
      FileUtils.mkdir_p(File.join(dir, CARTHAGE_FRAMEWORK_EXAMPLE_PATH))

      paths = Fastlane::Helper::XcodeprojHelper.find(dir)
      expect(paths).to contain_exactly(path, secondary_path)
    end

    after do
      FileUtils.rm_rf(dir)
    end
  end
end
