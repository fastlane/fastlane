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

    describe '.save_project_build_setting' do
      it 'changes only the lines of the build setting in a project.pbxproj file' do
        project = Xcodeproj::Project.new(File.join(Dir.mktmpdir, "Project.xcodeproj"))
        build_settings = { "CURRENT_PROJECT_VERSION" => "1", "CURRENT_PROJECT_VERSION[sdk=iphoneos*]" => "1" }
        project.build_configurations.each { |config| config.build_settings.merge!(build_settings) }
        project.save
        project_file = File.join(project.path, "project.pbxproj")
        # Xcode 27 writes this key, and the xcodeproj gem removes it when the gem saves the project.
        content = File.read(project_file).sub(/^}$/, "\tvalidationLevel = 1;\n}")
        File.write(project_file, content)

        Fastlane::Helper::XcodeprojHelper.save_project_build_setting(project, "CURRENT_PROJECT_VERSION", "2-beta")

        expected_content = content
                           .gsub("CURRENT_PROJECT_VERSION = 1;", 'CURRENT_PROJECT_VERSION = "2-beta";')
                           .gsub('"CURRENT_PROJECT_VERSION[sdk=iphoneos*]" = 1;', '"CURRENT_PROJECT_VERSION[sdk=iphoneos*]" = "2-beta";')
        expect(File.read(project_file)).to eq(expected_content)
        saved_build_settings = Xcodeproj::Project.open(project.path).build_configurations.map(&:build_settings)
        expect(saved_build_settings.map { |settings| settings.values_at(*build_settings.keys) }).to eq([["2-beta", "2-beta"], ["2-beta", "2-beta"]])
      end

      it 'saves the project through the xcodeproj gem when the project has no project.pbxproj file' do
        project = double("project", path: File.join(Dir.mktmpdir, "Project.xcodeproj"))
        expect(project).to receive(:save)

        Fastlane::Helper::XcodeprojHelper.save_project_build_setting(project, "CURRENT_PROJECT_VERSION", "2")
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

    describe '.single_project_path' do
      it 'returns the given path' do
        expect(Fastlane::Helper::XcodeprojHelper.single_project_path("Other.xcodeproj")).to eq("Other.xcodeproj")
      end

      it 'returns the only project in the current directory' do
        FileUtils.mkdir_p(File.join(dir, PATH))

        expect(Dir.chdir(dir) { Fastlane::Helper::XcodeprojHelper.single_project_path(nil) }).to eq(PATH)
      end

      it 'returns nil when the current directory has more than one project' do
        FileUtils.mkdir_p(File.join(dir, PATH))
        FileUtils.mkdir_p(File.join(dir, "Other.xcodeproj"))

        expect(Dir.chdir(dir) { Fastlane::Helper::XcodeprojHelper.single_project_path(nil) }).to be_nil
      end
    end

    describe 'Info.plist helpers' do
      let(:build_configuration) { Struct.new(:build_settings) }

      # Returns a project double whose single target uses the given INFOPLIST_FILE values.
      def project_with_info_plists(*info_plist_files)
        configs = info_plist_files.map { |file| build_configuration.new({ "INFOPLIST_FILE" => file }) }
        double("project", build_configurations: [], targets: [double("target", build_configurations: configs)], project_dir: Pathname.new(dir))
      end

      def write_plist(name, contents)
        path = File.join(dir, name)
        FileUtils.mkdir_p(File.dirname(path))
        Xcodeproj::Plist.write_to_path(contents, path)
        path
      end

      it 'resolves Info.plist paths against the project directory' do
        relative = write_plist("App/Info.plist", {})
        srcroot = write_plist("Extension/Info.plist", {})
        srcroot_in_braces = write_plist("Intents/Info.plist", {})
        project_dir = write_plist("Watch/Info.plist", {})
        absolute = write_plist("Widget/Info.plist", {})
        project = project_with_info_plists("App/Info.plist", "$(SRCROOT)/Extension/Info.plist", "${SRCROOT}/Intents/Info.plist", "$(PROJECT_DIR)/Watch/Info.plist", absolute, "$(BUILT_PRODUCTS_DIR)/Info.plist", "Missing/Info.plist")

        expect(Fastlane::Helper::XcodeprojHelper.info_plist_paths(project)).to eq([relative, srcroot, srcroot_in_braces, project_dir, absolute].sort)
      end

      it 'reads a key from the Info.plist files that have it' do
        write_plist("App/Info.plist", { "CFBundleShortVersionString" => "1.0" })
        write_plist("Extension/Info.plist", {})
        project = project_with_info_plists("App/Info.plist", "Extension/Info.plist")

        expect(Fastlane::Helper::XcodeprojHelper.info_plist_values(project, "CFBundleShortVersionString")).to eq(["1.0"])
      end

      it 'updates literal values and keeps build setting references and missing keys' do
        literal = write_plist("App/Info.plist", { "CFBundleVersion" => "1" })
        reference = write_plist("Extension/Info.plist", { "CFBundleVersion" => "$(CURRENT_PROJECT_VERSION)" })
        missing = write_plist("Widget/Info.plist", {})
        project = project_with_info_plists("App/Info.plist", "Extension/Info.plist", "Widget/Info.plist")

        changed = Fastlane::Helper::XcodeprojHelper.update_info_plist_value(project, "CFBundleVersion", "2")

        expect(changed).to eq([literal])
        expect(Xcodeproj::Plist.read_from_path(literal)["CFBundleVersion"]).to eq("2")
        expect(Xcodeproj::Plist.read_from_path(reference)["CFBundleVersion"]).to eq("$(CURRENT_PROJECT_VERSION)")
        expect(Xcodeproj::Plist.read_from_path(missing)).not_to have_key("CFBundleVersion")
      end

      describe 'with an Info.plist that Xcode wrote' do
        let(:info_plist) { File.join(dir, "Info.plist") }
        let(:project) { project_with_info_plists("Info.plist") }

        # Writes an Info.plist whose keys are not sorted, and which has a comment, a date and a data value.
        def write_info_plist(version)
          File.write(info_plist, <<~PLIST)
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
            	<key>UILaunchStoryboardName</key>
            	<string>Launch</string>
            	<!-- The build number -->
            	<key>CFBundleVersion</key>
            	#{version}
            	<key>BuildDate</key>
            	<date>2026-01-02T03:04:05Z</date>
            	<key>Signature</key>
            	<data>AQID</data>
            </dict>
            </plist>
          PLIST
        end

        it 'changes only the value of the key' do
          write_info_plist("<string>1</string>")
          expected = File.read(info_plist).sub("<string>1</string>", "<string>2 &amp; 3</string>")

          Fastlane::Helper::XcodeprojHelper.update_info_plist_value(project, "CFBundleVersion", "2 & 3")

          expect(File.read(info_plist)).to eq(expected)
          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("2 & 3")
        end

        it 'raises an exception and keeps the file when the value is not a string' do
          write_info_plist("<integer>1</integer>")
          original = File.read(info_plist)

          expect do
            Fastlane::Helper::XcodeprojHelper.update_info_plist_value(project, "CFBundleVersion", "2")
          end.to raise_error(/does not store it as an XML string/)
          expect(File.read(info_plist)).to eq(original)
        end
      end
    end

    after do
      FileUtils.rm_rf(dir)
    end
  end
end
