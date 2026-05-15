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

    describe '.get_project!' do
      it 'opens the given Xcode project' do
        expect(Xcodeproj::Project).to receive(:open)
          .with(File.join(dir, PATH))
          .and_return(:project)

        FileUtils.mkdir_p(File.join(dir, PATH))

        expect(Fastlane::Helper::XcodeprojHelper.get_project!(File.join(dir, PATH))).to eq(:project)
      end

      it 'opens the first Xcode project in the given directory' do
        path = File.join(dir, PATH)
        FileUtils.mkdir_p(path)

        expect(Xcodeproj::Project).to receive(:open)
          .with(path)
          .and_return(:project)

        expect(Fastlane::Helper::XcodeprojHelper.get_project!(dir)).to eq(:project)
      end

      it 'raises when no Xcode project can be found' do
        expect do
          Fastlane::Helper::XcodeprojHelper.get_project!(dir)
        end.to raise_error("Unable to find Xcode project at #{dir}")
      end
    end

    describe '.update_project_build_setting' do
      it 'updates matching build settings in the project and targets' do
        build_configuration = Struct.new(:build_settings)
        project_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
        target_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
        other_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
        target = double("target", build_configurations: [target_config, other_config])
        project = double("project", build_configurations: [project_config], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(true)
        expect(project_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(target_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(other_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
      end

      it 'returns false when no build setting matches' do
        build_configuration = Struct.new(:build_settings)
        project_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
        target_config = build_configuration.new({ "PRODUCT_BUNDLE_IDENTIFIER" => "tools.fastlane.example" })
        target = double("target", build_configurations: [target_config])
        project = double("project", build_configurations: [project_config], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(false)
        expect(project_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
        expect(target_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]).to eq("tools.fastlane.example")
      end
    end

    after do
      FileUtils.rm_rf(dir)
    end
  end
end
