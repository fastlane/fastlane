# The Xcodeproj gem is still a dependency of fastlane (the actions that modify a project use it).
# While that is the case, this spec pins FastlaneCore::Xcode to the gem's behaviour on every
# fixture project in the repository, so the two cannot drift apart unnoticed.
describe "FastlaneCore::Xcode parity with the Xcodeproj gem" do
  require 'xcodeproj'

  fixture_roots = %w[
    fastlane_core/spec/fixtures/projects
    gym/spec/fixtures/projects
    gym/examples
    fastlane/spec/fixtures/xcodeproj
    fastlane/spec/fixtures/actions/get_version_number
  ]
  projects = fixture_roots.flat_map { |root| Dir["#{root}/**/*.xcodeproj"] }.select { |p| File.exist?(File.join(p, "project.pbxproj")) }.sort
  workspaces = fixture_roots.flat_map { |root| Dir["#{root}/**/*.xcworkspace"] }.reject { |p| p.end_with?("project.xcworkspace") }.sort
  schemes = fixture_roots.flat_map { |root| Dir["#{root}/**/*.xcscheme"] }.sort
  settings = %w[SDKROOT PRODUCT_BUNDLE_IDENTIFIER PROVISIONING_PROFILE_SPECIFIER PROVISIONING_PROFILE INFOPLIST_FILE MARKETING_VERSION CURRENT_PROJECT_VERSION CODE_SIGN_IDENTITY DEVELOPMENT_TEAM PRODUCT_NAME TEST_HOST]

  it "finds fixtures to compare" do
    expect(projects.count).to be > 10
    expect(workspaces.count).to be > 2
    expect(schemes.count).to be > 10
  end

  projects.each do |project_path|
    describe project_path do
      let(:theirs) { Xcodeproj::Project.open(project_path) }
      let(:ours) { FastlaneCore::Xcode::Project.open(project_path) }

      it "reads the same targets, configurations, attributes and file paths" do
        expect(ours.targets.map(&:name)).to eq(theirs.targets.map(&:name))
        expect(ours.native_targets.map(&:name)).to eq(theirs.native_targets.map(&:name))
        expect(ours.build_configurations.map(&:name)).to eq(theirs.build_configurations.map(&:name))
        expect(ours.root_object.attributes).to eq(theirs.root_object.attributes || {})
        expect(ours.files.map(&:real_path).sort).to eq(theirs.files.map { |f| f.real_path.to_s }.sort)
        expect(ours.objects.grep(FastlaneCore::Xcode::Project::BuildConfiguration).map(&:build_settings).sort_by(&:to_s))
          .to eq(theirs.objects.select { |o| o.isa == 'XCBuildConfiguration' }.map { |o| o.to_hash['buildSettings'] }.sort_by(&:to_s))
        expect(FastlaneCore::Xcode::Project.schemes(project_path)).to eq(Xcodeproj::Project.schemes(project_path))
      end

      it "resolves build settings the same way" do
        theirs.targets.each do |their_target|
          our_target = ours.targets.find { |t| t.name == their_target.name }
          their_test = their_target.respond_to?(:test_target_type?) && their_target.test_target_type?
          expect(our_target.test_target_type?).to eq(their_test), "#{their_target.name} test_target_type?"

          settings.each do |key|
            [true, false].each do |resolve|
              expect(our_target.resolved_build_setting(key, resolve)).to eq(their_target.resolved_build_setting(key, resolve)), "#{their_target.name} resolved_build_setting(#{key}, #{resolve})"
            end
          end

          their_target.build_configurations.each do |their_config|
            our_config = our_target.build_configuration(their_config.name)
            expect(our_config.base_configuration_reference&.real_path).to eq(their_config.base_configuration_reference&.real_path&.to_s)
            settings.each do |key|
              expect(our_config.resolve_build_setting(key, our_target)).to eq(their_config.resolve_build_setting(key, their_target)), "#{their_target.name}/#{their_config.name} #{key} (with target)"
              expect(our_config.resolve_build_setting(key)).to eq(their_config.resolve_build_setting(key)), "#{their_target.name}/#{their_config.name} #{key}"
            end
          end
        end

        theirs.build_configurations.each do |their_config|
          our_config = ours.build_configuration_list.build_configuration(their_config.name)
          settings.each do |key|
            expect(our_config.resolve_build_setting(key)).to eq(their_config.resolve_build_setting(key)), "project/#{their_config.name} #{key}"
          end
        end
      end
    end
  end

  workspaces.each do |workspace_path|
    it "reads #{workspace_path} the same way" do
      theirs = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
      ours = FastlaneCore::Xcode::Workspace.open(workspace_path)
      workspace_dir = File.expand_path("..", workspace_path)
      expect(ours.file_references.map { |r| [r.path, r.type] }).to eq(theirs.file_references.map { |r| [r.path, r.type] })
      expect(ours.file_references.map { |r| r.absolute_path(workspace_dir) }).to eq(theirs.file_references.map { |r| r.absolute_path(workspace_dir) })
      # Xcodeproj also lists loose (non-project) files of the workspace as schemes, which we deliberately don't
      expect(ours.schemes).to eq(theirs.schemes.select { |_, path| path.end_with?(".xcodeproj", ".xcworkspace") })
    end
  end

  schemes.each do |scheme_path|
    it "reads the archive configuration of #{scheme_path} the same way" do
      expect(FastlaneCore::Xcode::Scheme.new(scheme_path).archive_build_configuration).to eq(Xcodeproj::XCScheme.new(scheme_path).archive_action.build_configuration)
    end
  end
end
