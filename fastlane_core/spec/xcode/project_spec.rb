describe FastlaneCore::Xcode::Project do
  let(:dir) { Dir.mktmpdir("fl_xcode_project") }
  after { FileUtils.remove_entry(dir) }

  # A small but realistic project: an app target and a unit test target, project-level
  # settings, a base xcconfig on the app's Release configuration, a group hierarchy and
  # file references with every source tree.
  let(:pbxproj) do
    <<~PBXPROJ
      // !$*UTF8*$!
      {
        archiveVersion = 1;
        objectVersion = 56;
        objects = {
          ROOT /* Project object */ = {
            isa = PBXProject;
            attributes = {
              LastUpgradeCheck = 1500;
              TargetAttributes = {
                APP = { ProvisioningStyle = Manual; };
                TESTS = { TestTargetID = APP; };
              };
            };
            buildConfigurationList = PROJ_CONFIGS;
            mainGroup = MAIN;
            projectDirPath = "";
            targets = (
              APP,
              TESTS,
              AGGREGATE,
            );
          };
          PROJ_CONFIGS = { isa = XCConfigurationList; buildConfigurations = ( PROJ_DEBUG, PROJ_RELEASE ); };
          PROJ_DEBUG = {
            isa = XCBuildConfiguration;
            name = Debug;
            buildSettings = {
              MARKETING_VERSION = 1.0.0;
              SDKROOT = iphoneos;
              INFOPLIST_FILE = "$(SRCROOT)/App/Info.plist";
              COMPANY = Example;
              HEADER_SEARCH_PATHS = ( "$(SRCROOT)/Headers", "$(SRCROOT)/More" );
            };
          };
          PROJ_RELEASE = {
            isa = XCBuildConfiguration;
            name = Release;
            baseConfigurationReference = XCCONFIG_PROJECT;
            buildSettings = {
              MARKETING_VERSION = 1.0.0;
              SDKROOT = iphoneos;
              INFOPLIST_FILE = "App/Info.plist";
              COMPANY = Example;
            };
          };

          APP /* App */ = {
            isa = PBXNativeTarget;
            name = App;
            productName = App;
            productType = "com.apple.product-type.application";
            buildConfigurationList = APP_CONFIGS;
          };
          APP_CONFIGS = { isa = XCConfigurationList; buildConfigurations = ( APP_DEBUG, APP_RELEASE ); };
          APP_DEBUG = {
            isa = XCBuildConfiguration;
            name = Debug;
            buildSettings = {
              PRODUCT_BUNDLE_IDENTIFIER = "com.$(COMPANY).app.$(CONFIGURATION)";
              PROVISIONING_PROFILE_SPECIFIER = "match Development com.example.app";
              HEADER_SEARCH_PATHS = ( "$(inherited)", "$(SRCROOT)/AppHeaders" );
              SELF_REFERENCE = "$(SELF_REFERENCE)/x";
              PING = "$(PONG)";
              PONG = "$(PING)";
            };
          };
          APP_RELEASE = {
            isa = XCBuildConfiguration;
            name = Release;
            baseConfigurationReference = XCCONFIG_APP;
            buildSettings = {
              PRODUCT_BUNDLE_IDENTIFIER = "$(inherited).release";
              MARKETING_VERSION = "$(inherited)";
            };
          };

          TESTS /* AppTests */ = {
            isa = PBXNativeTarget;
            name = AppTests;
            productType = "com.apple.product-type.bundle.unit-test";
            buildConfigurationList = TESTS_CONFIGS;
          };
          TESTS_CONFIGS = { isa = XCConfigurationList; buildConfigurations = ( TESTS_DEBUG ); };
          TESTS_DEBUG = {
            isa = XCBuildConfiguration;
            name = Debug;
            buildSettings = { TEST_HOST = "$(BUILT_PRODUCTS_DIR)/App.app/App"; };
          };

          AGGREGATE = {
            isa = PBXAggregateTarget;
            name = Everything;
            buildConfigurationList = PROJ_CONFIGS;
          };

          MAIN = { isa = PBXGroup; children = ( CONFIG_GROUP, INFO_PLIST, SOURCE_ROOT_FILE, ABSOLUTE_FILE, PRODUCT ); sourceTree = "<group>"; };
          CONFIG_GROUP = { isa = PBXGroup; name = Configurations; path = Config; children = ( XCCONFIG_PROJECT, TARGET_GROUP ); sourceTree = "<group>"; };
          TARGET_GROUP = { isa = PBXGroup; path = Targets; children = ( XCCONFIG_APP ); sourceTree = "<group>"; };
          XCCONFIG_PROJECT = { isa = PBXFileReference; path = Project.xcconfig; sourceTree = "<group>"; };
          XCCONFIG_APP = { isa = PBXFileReference; path = App.xcconfig; sourceTree = "<group>"; };
          INFO_PLIST = { isa = PBXFileReference; name = "Info.plist"; path = "App/Info.plist"; sourceTree = "<group>"; };
          SOURCE_ROOT_FILE = { isa = PBXFileReference; path = "Settings.bundle"; sourceTree = SOURCE_ROOT; };
          ABSOLUTE_FILE = { isa = PBXFileReference; path = "/usr/lib/libz.tbd"; sourceTree = "<absolute>"; };
          PRODUCT = { isa = PBXFileReference; path = App.app; sourceTree = BUILT_PRODUCTS_DIR; };
        };
        rootObject = ROOT /* Project object */;
      }
    PBXPROJ
  end

  let(:project_path) { File.join(dir, "Sample.xcodeproj") }
  let(:project) { FastlaneCore::Xcode::Project.open(project_path) }

  before do
    FileUtils.mkdir_p(project_path)
    File.write(File.join(project_path, "project.pbxproj"), pbxproj)
    FileUtils.mkdir_p(File.join(dir, "Config/Targets"))
    File.write(File.join(dir, "Config/Common.xcconfig"), "COMPANY = included\nTEAM = TEAM123\n")
    File.write(File.join(dir, "Config/Project.xcconfig"), "#include \"Common.xcconfig\"\nCOMPANY = xcconfig\nMARKETING_VERSION = 2.0.0\n")
    File.write(File.join(dir, "Config/Targets/App.xcconfig"), "PROVISIONING_PROFILE_SPECIFIER = match AppStore com.example.app\nMARKETING_VERSION = $(inherited).1\n")
  end

  describe ".open" do
    it "raises for a missing project" do
      expect { FastlaneCore::Xcode::Project.open(File.join(dir, "Missing.xcodeproj")) }.to raise_error(FastlaneCore::Xcode::Error, /doesn't exist/)
    end

    it "raises for a project file that is not a pbxproj" do
      File.write(File.join(project_path, "project.pbxproj"), "{ archiveVersion = 1; }")
      expect { project }.to raise_error(FastlaneCore::Xcode::Error, /not a valid Xcode project/)
    end

    it "exposes the paths" do
      expect(project.path).to eq(project_path)
      expect(project.project_dir).to eq(dir)
    end
  end

  describe "project attributes" do
    it "reads the root object attributes" do
      expect(project.root_object.isa).to eq("PBXProject")
      expect(project.root_object.attributes["TargetAttributes"]).to eq({ "APP" => { "ProvisioningStyle" => "Manual" }, "TESTS" => { "TestTargetID" => "APP" } })
    end

    it "lists the project build configurations" do
      expect(project.build_configurations.map(&:name)).to eq(%w[Debug Release])
      expect(project.build_configuration_list.build_configuration("Release").build_settings["INFOPLIST_FILE"]).to eq("App/Info.plist")
    end

    it "lists every build configuration in the file" do
      expect(project.objects.grep(FastlaneCore::Xcode::Project::BuildConfiguration).count).to eq(5)
    end
  end

  describe "targets" do
    it "lists all targets in order and tells native ones apart" do
      expect(project.targets.map(&:name)).to eq(%w[App AppTests Everything])
      expect(project.native_targets.map(&:name)).to eq(%w[App AppTests])
      expect(project.targets.map(&:native?)).to eq([true, true, false])
    end

    it "detects test targets" do
      expect(project.targets.map(&:test_target_type?)).to eq([false, true, false])
    end

    it "lists the configurations of a target" do
      expect(project.targets.first.build_configurations.map(&:name)).to eq(%w[Debug Release])
      expect(project.targets.first.build_configuration("Release").build_settings["PRODUCT_BUNDLE_IDENTIFIER"]).to eq("$(inherited).release")
    end
  end

  describe "#resolve_build_setting" do
    let(:app) { project.targets.first }
    let(:debug) { app.build_configuration("Debug") }
    let(:release) { app.build_configuration("Release") }

    it "expands variables against the target, falling back to the project, and knows CONFIGURATION" do
      expect(debug.resolve_build_setting("PRODUCT_BUNDLE_IDENTIFIER", app)).to eq("com.Example.app.Debug")
    end

    it "expands $(SRCROOT) to the project directory" do
      expect(debug.resolve_build_setting("INFOPLIST_FILE", app)).to eq("#{dir}/App/Info.plist")
    end

    it "inherits project settings that the target does not define" do
      expect(debug.resolve_build_setting("SDKROOT", app)).to eq("iphoneos")
      expect(debug.resolve_build_setting("MARKETING_VERSION", app)).to eq("1.0.0")
    end

    it "returns nil for unknown settings" do
      expect(debug.resolve_build_setting("NOPE", app)).to be_nil
    end

    it "layers xcconfig files: target build settings > target xcconfig > project build settings > project xcconfig" do
      # the project build setting (1.0.0) beats the project xcconfig (2.0.0), the target xcconfig appends .1 via
      # $(inherited), and the target build setting is a bare $(inherited)
      expect(release.resolve_build_setting("MARKETING_VERSION", app)).to eq("1.0.0.1")
      # project build settings win over the project xcconfig and its includes
      expect(release.resolve_build_setting("COMPANY", app)).to eq("Example")
      # a value only defined by an included xcconfig is still visible
      expect(release.resolve_build_setting("TEAM", app)).to eq("TEAM123")
      expect(release.resolve_build_setting("PROVISIONING_PROFILE_SPECIFIER", app)).to eq("match AppStore com.example.app")
    end

    it "replaces $(inherited) with the project value" do
      expect(release.resolve_build_setting("PRODUCT_BUNDLE_IDENTIFIER", app)).to be_nil.or(eq(".release"))
      expect(debug.resolve_build_setting("HEADER_SEARCH_PATHS", app)).to eq(["#{dir}/Headers", "#{dir}/More", "#{dir}/AppHeaders"])
    end

    it "does not loop on self references or mutual recursion, and resolves them to nil like Xcodeproj" do
      expect(debug.resolve_build_setting("SELF_REFERENCE", app)).to be_nil
      expect(debug.resolve_build_setting("PING", app)).to be_nil
    end

    it "lets an environment variable of the same name win" do
      FastlaneSpec::Env.with_env_values("SDKROOT" => "macosx") do
        expect(debug.resolve_build_setting("SDKROOT", app)).to eq("macosx")
      end
    end

    it "keeps source trees Xcode resolves at build time as variables" do
      tests = project.targets[1]
      expect(tests.build_configuration("Debug").resolve_build_setting("TEST_HOST", tests)).to eq("/App.app/App")
    end
  end

  describe "#resolved_build_setting" do
    let(:app) { project.targets.first }

    it "returns raw values per configuration, target values winning over project values" do
      expect(app.resolved_build_setting("INFOPLIST_FILE")).to eq({ "Debug" => "$(SRCROOT)/App/Info.plist", "Release" => "App/Info.plist" })
      expect(app.resolved_build_setting("PRODUCT_BUNDLE_IDENTIFIER")).to eq({ "Debug" => "com.$(COMPANY).app.$(CONFIGURATION)", "Release" => "$(inherited).release" })
    end

    it "substitutes $(inherited) in a target value with the project value" do
      expect(app.resolved_build_setting("MARKETING_VERSION")).to eq({ "Debug" => "1.0.0", "Release" => "1.0.0" })
    end

    it "resolves against xcconfig files when asked" do
      expect(app.resolved_build_setting("MARKETING_VERSION", true)).to eq({ "Debug" => "1.0.0", "Release" => "1.0.0.1" })
      expect(app.resolved_build_setting("INFOPLIST_FILE", true)).to eq({ "Debug" => "#{dir}/App/Info.plist", "Release" => "App/Info.plist" })
    end
  end

  describe "file references" do
    it "resolves real paths through the group hierarchy and every source tree" do
      paths = project.files.map { |file| [file.display_name, file.real_path] }.to_h
      expect(paths).to eq({
        "Project.xcconfig" => File.join(dir, "Config/Project.xcconfig"),
        "App.xcconfig" => File.join(dir, "Config/Targets/App.xcconfig"),
        "Info.plist" => File.join(dir, "App/Info.plist"),
        "Settings.bundle" => File.join(dir, "Settings.bundle"),
        "libz.tbd" => "/usr/lib/libz.tbd",
        "App.app" => "${BUILT_PRODUCTS_DIR}/App.app"
      })
    end

    it "exposes the base configuration reference of a configuration" do
      release = project.targets.first.build_configuration("Release")
      expect(release.base_configuration_reference.real_path).to eq(File.join(dir, "Config/Targets/App.xcconfig"))
      expect(project.targets.first.build_configuration("Debug").base_configuration_reference).to be_nil
    end

    it "honours projectDirPath" do
      File.write(File.join(project_path, "project.pbxproj"), pbxproj.sub('projectDirPath = "";', 'projectDirPath = "Sources";'))
      expect(project.files.find { |f| f.display_name == "Info.plist" }.real_path).to eq(File.join(dir, "Sources/App/Info.plist"))
    end
  end

  describe ".schemes" do
    it "lists shared schemes" do
      FileUtils.mkdir_p(File.join(project_path, "xcshareddata/xcschemes"))
      FileUtils.touch(File.join(project_path, "xcshareddata/xcschemes/App.xcscheme"))
      FileUtils.touch(File.join(project_path, "xcshareddata/xcschemes/App Dev.xcscheme"))
      expect(FastlaneCore::Xcode::Project.schemes(project_path)).to contain_exactly("App", "App Dev")
    end

    it "falls back to the project name when nothing is shared" do
      expect(FastlaneCore::Xcode::Project.schemes(project_path)).to eq(["Sample"])
    end
  end

  describe "with a real project" do
    let(:project) { FastlaneCore::Xcode::Project.open("./fastlane_core/spec/fixtures/projects/Example.xcodeproj") }

    it "reads targets and configurations" do
      expect(project.targets.map(&:name)).to eq(%w[Example ExampleTests ExampleUITests])
      expect(project.build_configurations.map(&:name)).to eq(%w[Debug Release SpecialConfiguration])
      expect(project.targets.first.resolved_build_setting("INFOPLIST_FILE")).to eq({ "Debug" => "Example/Info.plist", "Release" => "Example/Info.plist", "SpecialConfiguration" => "Example/Info.plist" })
    end
  end
end
