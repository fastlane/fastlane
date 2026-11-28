describe Fastlane::Helper::AgvtoolHelper do
  around do |example|
    Dir.mktmpdir('fl_spec_agvtool') do |dir|
      @folder = File.join(dir, 'standard')
      FileUtils.cp_r('./gym/examples/standard', @folder)
      example.run
    end
  end

  let(:pbxproj) { File.join(@folder, 'Example.xcodeproj', 'project.pbxproj') }
  let(:info_plist) { File.join(@folder, 'Example', 'Info.plist') }

  it 'covers the project and every target Info.plist' do
    files = described_class.files_agvtool_edits(@folder).map { |path| path.delete_prefix("#{File.realpath(@folder)}/").delete_prefix("#{@folder}/") }
    expect(files).to contain_exactly('Example.xcodeproj/project.pbxproj', 'Example/Info.plist', 'ExampleTests/Info.plist', 'ExampleUITests/Info.plist')
  end

  it 'puts the project back when agvtool empties it' do
    original = File.binread(pbxproj)
    allow(Fastlane::Actions).to receive(:sh) do
      File.write(pbxproj, '')
      'Setting version of project Example to: release/1.2.3.'
    end

    expect do
      described_class.run('agvtool new-marketing-version release/1.2.3', folder: @folder)
    end.to raise_error(described_class::DamagedProjectError, %r{Example.xcodeproj/project.pbxproj.*agvtool printed: Setting version})
    expect(File.binread(pbxproj)).to eq(original)
  end

  it 'puts every file back when agvtool breaks an Info.plist' do
    originals = [pbxproj, info_plist].to_h { |path| [path, File.binread(path)] }
    allow(Fastlane::Actions).to receive(:sh) do
      File.write(pbxproj, originals[pbxproj].sub('CURRENT_PROJECT_VERSION', 'CURRENT_PROJECT_VERSION_CHANGED'))
      File.write(info_plist, '<plist><dict><key>CFBundleShortVersionString</key><string>1 & 2</string>')
      ''
    end

    expect do
      described_class.run('agvtool new-marketing-version "1 & 2"', folder: @folder)
    end.to raise_error(described_class::DamagedProjectError, %r{Example/Info.plist})
    originals.each { |path, content| expect(File.binread(path)).to eq(content) }
  end

  it 'returns the output and keeps the changes when the files stay readable' do
    version = "<key>CFBundleShortVersionString</key>\n\t<string>%s</string>"
    allow(Fastlane::Actions).to receive(:sh) do
      File.write(info_plist, File.read(info_plist).sub(format(version, '1.0'), format(version, '2.0')))
      'done'
    end

    expect(described_class.run('agvtool new-marketing-version 2.0', folder: @folder)).to eq('done')
    expect(File.read(info_plist)).to include(format(version, '2.0'))
  end

  it 'keeps a real agvtool from emptying the project', requires_xcode: true do
    original = File.binread(pbxproj)
    allow(Fastlane::Actions).to receive(:sh).and_wrap_original { |sh, command| sh.call(command, log: false) }
    stub_const('ENV', ENV.to_h.merge('FORCE_SH_DURING_TESTS' => '1'))

    expect do
      described_class.run("cd #{@folder.shellescape} && agvtool new-marketing-version release/1.2.3", folder: @folder)
    end.to raise_error(described_class::DamagedProjectError)
    expect(File.binread(pbxproj)).to eq(original)
  end
end
