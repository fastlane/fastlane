describe FastlaneCore::Xcode::Plist do
  let(:dir) { Dir.mktmpdir("fl_xcode_plist") }
  after { FileUtils.remove_entry(dir) }

  it "reads XML plists" do
    path = File.join(dir, "Info.plist")
    File.write(path, '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleShortVersionString</key><string>1.2.3</string><key>Flag</key><true/><key>Count</key><integer>3</integer></dict></plist>')
    expect(FastlaneCore::Xcode::Plist.read_from_path(path)).to eq({ "CFBundleShortVersionString" => "1.2.3", "Flag" => true, "Count" => 3 })
  end

  it "reads binary plists" do
    path = File.join(dir, "Binary.plist")
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess({ "Key" => "Value", "Nested" => { "N" => 1 } })
    plist.save(path, CFPropertyList::List::FORMAT_BINARY)
    expect(FastlaneCore::Xcode::Plist.read_from_path(path)).to eq({ "Key" => "Value", "Nested" => { "N" => 1 } })
  end

  it "reads old-style ASCII plists" do
    path = File.join(dir, "Ascii.plist")
    File.write(path, '{ CFBundleShortVersionString = "4.5.6"; Items = (a, b); }')
    expect(FastlaneCore::Xcode::Plist.read_from_path(path)).to eq({ "CFBundleShortVersionString" => "4.5.6", "Items" => %w[a b] })
  end

  it "raises for a missing file" do
    expect { FastlaneCore::Xcode::Plist.read_from_path(File.join(dir, "nope.plist")) }.to raise_error(FastlaneCore::Xcode::Error, /doesn't exist/)
  end

  it "raises for a file with merge conflict markers" do
    path = File.join(dir, "Conflict.plist")
    File.write(path, "<<<<<<< HEAD\n<plist/>\n=======\n<plist/>\n>>>>>>> branch\n")
    expect { FastlaneCore::Xcode::Plist.read_from_path(path) }.to raise_error(FastlaneCore::Xcode::Error, /merge conflict/)
  end

  it "writes XML plists that it can read back, converting symbol keys" do
    path = File.join(dir, "Out.plist")
    FastlaneCore::Xcode::Plist.write_to_path({ "String" => "value", :symbol => true, "Array" => ["a", 1, false], "Nested" => { "Real" => 1.5 } }, path)
    content = File.read(path)
    expect(content).to start_with('<?xml version="1.0" encoding="UTF-8"?>')
    expect(content).to include("<key>symbol</key>\n\t<true/>")
    expect(FastlaneCore::Xcode::Plist.read_from_path(path)).to eq({ "String" => "value", "symbol" => true, "Array" => ["a", 1, false], "Nested" => { "Real" => 1.5 } })
  end
end
