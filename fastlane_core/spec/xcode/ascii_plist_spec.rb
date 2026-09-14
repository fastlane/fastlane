describe FastlaneCore::Xcode::AsciiPlist do
  def parse(string)
    FastlaneCore::Xcode::AsciiPlist.parse(string)
  end

  it "parses dictionaries, arrays, quoted and unquoted strings" do
    plist = <<~PLIST
      // !$*UTF8*$!
      {
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 56;
        "quoted key" = "quoted value";
        path = "path/with spaces.xcconfig";
        list = (
          one,
          "two words",
          3,
        );
        empty = ( );
        trailing = (a, b);
      }
    PLIST

    expect(parse(plist)).to eq({
      "archiveVersion" => "1",
      "classes" => {},
      "objectVersion" => "56",
      "quoted key" => "quoted value",
      "path" => "path/with spaces.xcconfig",
      "list" => ["one", "two words", "3"],
      "empty" => [],
      "trailing" => %w[a b]
    })
  end

  it "keeps every scalar as a string, like Xcodeproj does" do
    expect(parse("{ number = 42; yes = YES; version = 1.2.3; }")).to eq({ "number" => "42", "yes" => "YES", "version" => "1.2.3" })
  end

  it "skips block comments and line comments, including the ones Xcode adds after object ids" do
    plist = <<~PLIST
      {
        /* Begin PBXProject section */
        A1 /* Project object */ = {
          isa = PBXProject; // trailing comment
          mainGroup = B2 /* Main */;
        };
        /* End PBXProject section */
      }
    PLIST
    expect(parse(plist)).to eq({ "A1" => { "isa" => "PBXProject", "mainGroup" => "B2" } })
  end

  it "does not treat comment markers inside quoted strings as comments" do
    plist = '{ shellScript = "echo \"http://example.com\" # /* not a comment */ // nor this"; }'
    expect(parse(plist)).to eq({ "shellScript" => 'echo "http://example.com" # /* not a comment */ // nor this' })
  end

  it "unescapes quoted strings" do
    plist = '{ a = "line\nbreak"; b = "tab\there"; c = "back\\\\slash"; d = "quote\"d"; e = "\U00e9"; f = "\101"; }'
    expect(parse(plist)).to eq({
      "a" => "line\nbreak",
      "b" => "tab\there",
      "c" => "back\\slash",
      "d" => 'quote"d',
      "e" => "é",
      "f" => "A"
    })
  end

  it "parses data" do
    expect(parse("{ blob = <48656c6c 6f>; }")).to eq({ "blob" => "Hello" })
  end

  it "parses a top level string" do
    expect(parse('"just a string"')).to eq("just a string")
  end

  it "reports the position of a syntax error" do
    expect { parse("{\n  key = value\n}") }.to raise_error(FastlaneCore::Xcode::AsciiPlist::ParseError, /expected ';'.*line 3/)
    expect { parse("{ key = ") }.to raise_error(FastlaneCore::Xcode::AsciiPlist::ParseError, /unexpected end of input/)
    expect { parse("{ a = 1; } trailing") }.to raise_error(FastlaneCore::Xcode::AsciiPlist::ParseError, /after the end/)
  end

  it "parses a real project file" do
    hash = parse(File.read("./fastlane_core/spec/fixtures/projects/Example.xcodeproj/project.pbxproj"))
    expect(hash["objects"][hash["rootObject"]]["isa"]).to eq("PBXProject")
    expect(hash["objects"].values.map { |o| o["isa"] }).to include("PBXNativeTarget", "XCBuildConfiguration", "PBXFileReference")
  end
end
