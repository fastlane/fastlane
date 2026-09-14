describe FastlaneCore::Xcode::Xcconfig do
  let(:dir) { Dir.mktmpdir("fl_xcode_xcconfig") }
  after { FileUtils.remove_entry(dir) }

  def write(name, content)
    path = File.join(dir, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  it "parses assignments, ignores comments and strips whitespace" do
    path = write("A.xcconfig", <<~XCCONFIG)
      // A comment
      PRODUCT_BUNDLE_IDENTIFIER = com.example.app   // trailing
      EMPTY =
      CODE_SIGN_IDENTITY[sdk=iphoneos*] = iPhone Distribution
    XCCONFIG
    expect(FastlaneCore::Xcode::Xcconfig.load(path)).to eq({
      "PRODUCT_BUNDLE_IDENTIFIER" => "com.example.app",
      "EMPTY" => "",
      "CODE_SIGN_IDENTITY[sdk=iphoneos*]" => "iPhone Distribution"
    })
  end

  it "merges included files, with the including file winning" do
    write("Common/Base.xcconfig", "TEAM = BASE\nSHARED = from-base\n")
    write("Common/Extra.xcconfig", "EXTRA = yes\nSHARED = from-extra\n")
    path = write("Targets/App.xcconfig", <<~XCCONFIG)
      #include "../Common/Base.xcconfig"
      #include? "../Common/Extra"
      #include "../Common/Missing.xcconfig"
      TEAM = APP
    XCCONFIG
    expect(FastlaneCore::Xcode::Xcconfig.load(path)).to eq({ "TEAM" => "APP", "SHARED" => "from-extra", "EXTRA" => "yes" })
  end

  it "expands $(inherited) against an earlier assignment in the same file and drops bare inherited values" do
    path = write("B.xcconfig", "FLAGS = -a\nFLAGS = $(inherited) -b\nOTHER = $(inherited)\n")
    expect(FastlaneCore::Xcode::Xcconfig.load(path)).to eq({ "FLAGS" => "-a -b" })
  end

  it "survives circular includes" do
    write("X.xcconfig", "#include \"Y.xcconfig\"\nX = 1\n")
    path = write("Y.xcconfig", "#include \"X.xcconfig\"\nY = 2\n")
    expect(FastlaneCore::Xcode::Xcconfig.load(path)).to eq({ "X" => "1", "Y" => "2" })
  end

  it "returns an empty hash for a missing file" do
    expect(FastlaneCore::Xcode::Xcconfig.load(File.join(dir, "missing.xcconfig"))).to eq({})
  end
end
