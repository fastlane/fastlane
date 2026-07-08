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

        expect(changed).to eq(project: true, xcconfig: false)
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

        expect(changed).to eq(project: false, xcconfig: false)
        expect(project_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
        expect(target_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]).to eq("tools.fastlane.example")
      end

      it 'updates matching build settings in base xcconfig files' do
        xcconfig_path = File.join(dir, "Version.xcconfig")
        File.write(xcconfig_path, [
          "// keep this comment",
          "#include \"Base.xcconfig\"",
          "MARKETING_VERSION = 1.2.3 // trailing comment",
          "MARKETING_VERSION[sdk=iphoneos*] = 1.2.4",
          "MARKETING_VERSION[sdk=iphoneos*][arch=arm64] = 1.2.4",
          "MARKETING_VERSION[config=Release] = 1.2.5 /* release comment */",
          "CURRENT_PROJECT_VERSION = 42"
        ].join("\n") + "\n")
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: base_configuration_reference)
        target = double("target", build_configurations: [])
        project = double("project", build_configurations: [build_configuration], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "5.6.7")

        expect(changed).to eq(project: false, xcconfig: true)
        expect(File.read(xcconfig_path)).to eq([
          "// keep this comment",
          "#include \"Base.xcconfig\"",
          "MARKETING_VERSION = 5.6.7 // trailing comment",
          "MARKETING_VERSION[sdk=iphoneos*] = 5.6.7",
          "MARKETING_VERSION[sdk=iphoneos*][arch=arm64] = 5.6.7",
          "MARKETING_VERSION[config=Release] = 5.6.7 /* release comment */",
          "CURRENT_PROJECT_VERSION = 42"
        ].join("\n") + "\n")
      end

      it 'does not update build settings inside xcconfig block comments' do
        xcconfig_path = File.join(dir, "Version.xcconfig")
        File.write(xcconfig_path, [
          "/*",
          "MARKETING_VERSION = 1.2.3",
          "MARKETING_VERSION[sdk=iphoneos*] = 1.2.4",
          "*/",
          "MARKETING_VERSION = 2.3.4"
        ].join("\n") + "\n")
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: base_configuration_reference)
        target = double("target", build_configurations: [])
        project = double("project", build_configurations: [build_configuration], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "5.6.7")

        expect(changed).to eq(project: false, xcconfig: true)
        expect(File.read(xcconfig_path)).to eq([
          "/*",
          "MARKETING_VERSION = 1.2.3",
          "MARKETING_VERSION[sdk=iphoneos*] = 1.2.4",
          "*/",
          "MARKETING_VERSION = 5.6.7"
        ].join("\n") + "\n")
      end

      it 'updates matching build settings in included xcconfig files' do
        included_xcconfig_path = File.join(dir, "Version.xcconfig")
        File.write(included_xcconfig_path, [
          "MARKETING_VERSION = 1.2.3"
        ].join("\n") + "\n")
        release_xcconfig_path = File.join(dir, "ReleaseVersion.xcconfig")
        File.write(release_xcconfig_path, [
          "MARKETING_VERSION[config=Release] = 1.2.4"
        ].join("\n") + "\n")
        xcconfig_path = File.join(dir, "Debug.xcconfig")
        File.write(xcconfig_path, [
          "#include \"Version\"",
          "#include \"ReleaseVersion.xcconfig\"",
          "CURRENT_PROJECT_VERSION = 42"
        ].join("\n") + "\n")
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: base_configuration_reference)
        target = double("target", build_configurations: [])
        project = double("project", build_configurations: [build_configuration], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "5.6.7")

        expect(changed).to eq(project: false, xcconfig: true)
        expect(File.read(xcconfig_path)).to eq([
          "#include \"Version\"",
          "#include \"ReleaseVersion.xcconfig\"",
          "CURRENT_PROJECT_VERSION = 42"
        ].join("\n") + "\n")
        expect(File.read(included_xcconfig_path)).to eq([
          "MARKETING_VERSION = 5.6.7"
        ].join("\n") + "\n")
        expect(File.read(release_xcconfig_path)).to eq([
          "MARKETING_VERSION[config=Release] = 5.6.7"
        ].join("\n") + "\n")
      end

      it 'does not follow xcconfig includes inside block comments' do
        included_xcconfig_path = File.join(dir, "Version.xcconfig")
        included_xcconfig_content = [
          "MARKETING_VERSION = 1.2.3"
        ].join("\n") + "\n"
        File.write(included_xcconfig_path, included_xcconfig_content)
        xcconfig_path = File.join(dir, "Debug.xcconfig")
        File.write(xcconfig_path, [
          "/*",
          "#include \"Version\"",
          "*/",
          "CURRENT_PROJECT_VERSION = 42"
        ].join("\n") + "\n")
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: base_configuration_reference)
        target = double("target", build_configurations: [])
        project = double("project", build_configurations: [build_configuration], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "5.6.7")

        expect(changed).to eq(project: false, xcconfig: false)
        expect(File.read(included_xcconfig_path)).to eq(included_xcconfig_content)
      end

      it 'does not rewrite matching build settings when the value is already current' do
        build_configuration = Struct.new(:build_settings)
        project_config = build_configuration.new({ "MARKETING_VERSION" => "1.2.3" })
        target = double("target", build_configurations: [])
        project = double("project", build_configurations: [project_config], targets: [target])

        changed = Fastlane::Helper::XcodeprojHelper.update_project_build_setting(project, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(project: false, xcconfig: false)
      end
    end

    describe '.update_build_configuration_build_setting' do
      it 'updates an inline build setting' do
        build_configuration = double("build_configuration", build_settings: {
          "MARKETING_VERSION" => "1.0.0",
          "MARKETING_VERSION[sdk=iphoneos*]" => "1.0.1",
          "MARKETING_VERSION[sdk=iphoneos*][arch=arm64]" => "1.0.2",
          "CURRENT_PROJECT_VERSION" => "42"
        })

        changed = Fastlane::Helper::XcodeprojHelper.update_build_configuration_build_setting(build_configuration, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(project: true, xcconfig: false)
        expect(build_configuration.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(build_configuration.build_settings["MARKETING_VERSION[sdk=iphoneos*]"]).to eq("1.2.3")
        expect(build_configuration.build_settings["MARKETING_VERSION[sdk=iphoneos*][arch=arm64]"]).to eq("1.2.3")
        expect(build_configuration.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
      end

      it 'updates inline and xcconfig build settings in the same configuration' do
        xcconfig_path = File.join(dir, "Version.xcconfig")
        File.write(xcconfig_path, [
          "MARKETING_VERSION[sdk=iphoneos*] = 1.0.1",
          "MARKETING_VERSION[sdk=iphoneos*][arch=arm64] = 1.0.2"
        ].join("\n") + "\n")
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {
          "MARKETING_VERSION" => "1.0.0"
        }, base_configuration_reference: base_configuration_reference)

        changed = Fastlane::Helper::XcodeprojHelper.update_build_configuration_build_setting(build_configuration, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(project: true, xcconfig: true)
        expect(build_configuration.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(File.read(xcconfig_path)).to eq([
          "MARKETING_VERSION[sdk=iphoneos*] = 1.2.3",
          "MARKETING_VERSION[sdk=iphoneos*][arch=arm64] = 1.2.3"
        ].join("\n") + "\n")
      end

      it 'does not rewrite an xcconfig when the value is already current' do
        xcconfig_path = File.join(dir, "Version.xcconfig")
        content = [
          "MARKETING_VERSION = 1.2.3 // trailing comment"
        ].join("\n") + "\n"
        File.write(xcconfig_path, content)
        base_configuration_reference = double("base_configuration_reference", real_path: Pathname.new(xcconfig_path))
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: base_configuration_reference)

        changed = Fastlane::Helper::XcodeprojHelper.update_build_configuration_build_setting(build_configuration, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(project: false, xcconfig: false)
        expect(File.read(xcconfig_path)).to eq(content)
      end

      it 'returns unchanged when the build setting is not present inline or in an xcconfig' do
        build_configuration = double("build_configuration", build_settings: {}, base_configuration_reference: nil)

        changed = Fastlane::Helper::XcodeprojHelper.update_build_configuration_build_setting(build_configuration, "MARKETING_VERSION", "1.2.3")

        expect(changed).to eq(project: false, xcconfig: false)
      end
    end

    after do
      FileUtils.rm_rf(dir)
    end
  end
end
