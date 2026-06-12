require "open3"
require "tempfile"

describe "resign.sh" do
  RESIGN_SH_PATH = File.expand_path("../lib/assets/resign.sh", File.dirname(__FILE__))

  before(:all) do
    skip("resign.sh not found") unless File.exist?(RESIGN_SH_PATH)
    @resign_sh_content = File.read(RESIGN_SH_PATH)
  end

  before(:each) do
    skip("Tests require bash") if Gem.win_platform?
  end

  # Extract a bash function definition from resign.sh by counting brace depth
  def extract_function(content, func_name)
    lines = content.lines
    start_idx = lines.index { |l| l.match?(/^\s*function\s+#{Regexp.escape(func_name)}\b/) }
    raise "Function '#{func_name}' not found in resign.sh" unless start_idx

    depth = 0
    end_idx = nil
    lines[start_idx..].each_with_index do |line, i|
      depth += line.count('{') - line.count('}')
      if depth <= 0 && i > 0
        end_idx = start_idx + i
        break
      end
    end
    raise "Could not find end of function '#{func_name}'" unless end_idx

    lines[start_idx..end_idx].join
  end

  # Run a bash script and return [stdout, stderr, status]
  def run_bash(script)
    Open3.capture3("bash", "-c", script)
  end

  # ─── Group A: does_bundle_id_match ────────────────────────────────────
  describe "does_bundle_id_match" do
    before(:all) do
      skip("resign.sh not found") unless File.exist?(RESIGN_SH_PATH)
      @func = extract_function(@resign_sh_content, "does_bundle_id_match")
    end

    def check_match(pattern, bundle_id, mode = nil)
      script = <<~BASH
        #{@func}
        does_bundle_id_match "#{pattern}" "#{bundle_id}" #{mode ? "\"#{mode}\"" : '""'}
        echo $?
      BASH
      stdout, = run_bash(script)
      stdout.strip.split("\n").last.to_i
    end

    it "matches exact bundle IDs" do
      expect(check_match("com.example.app", "com.example.app")).to eq(0)
    end

    it "does not match different bundle IDs" do
      expect(check_match("com.example.app", "com.example.other")).to eq(1)
    end

    it "matches universal wildcard '*' to any bundle ID" do
      expect(check_match("*", "com.example.app")).to eq(0)
    end

    it "matches suffix wildcard 'com.example.*'" do
      expect(check_match("com.example.*", "com.example.app")).to eq(0)
    end

    it "does not match wildcard when prefix differs" do
      expect(check_match("com.example.*", "com.other.app")).to eq(1)
    end

    it "STRICT mode disables suffix wildcard" do
      expect(check_match("com.example.*", "com.example.app", "STRICT")).to eq(1)
    end

    it "STRICT mode disables universal wildcard" do
      expect(check_match("*", "com.example.app", "STRICT")).to eq(1)
    end

    it "STRICT mode still allows exact match" do
      expect(check_match("com.example.app", "com.example.app", "STRICT")).to eq(0)
    end

    it "matches middle wildcard 'com.*.app'" do
      expect(check_match("com.*.app", "com.example.app")).to eq(0)
    end

    it "wildcard matches nested bundle IDs" do
      expect(check_match("com.example.*", "com.example.app.ext")).to eq(0)
    end

    it "does not match when candidate has extra suffix" do
      expect(check_match("com.example.app", "com.example.app2")).to eq(1)
    end

    it "does not match when candidate is shorter" do
      expect(check_match("com.example.app", "com.example.ap")).to eq(1)
    end

    it "treats dots as literal characters" do
      expect(check_match("com.example.*", "comXexampleXapp")).to eq(1)
    end
  end

  # ─── Group B: provision_for_bundle_id ─────────────────────────────────
  describe "provision_for_bundle_id" do
    before(:all) do
      skip("resign.sh not found") unless File.exist?(RESIGN_SH_PATH)
      @match_func = extract_function(@resign_sh_content, "does_bundle_id_match")
      @provision_func = extract_function(@resign_sh_content, "provision_for_bundle_id")
    end

    def find_provision(provisions, bundle_id, mode = nil)
      provisions_bash = provisions.map { |k, v| "\"#{k}=#{v}\"" }.join(" ")
      script = <<~BASH
        #{@match_func}
        #{@provision_func}
        PROVISIONS_BY_ID=(#{provisions_bash})
        provision_for_bundle_id "#{bundle_id}" #{mode ? "\"#{mode}\"" : '""'}
      BASH
      stdout, = run_bash(script)
      stdout.strip
    end

    it "returns provision path for exact match" do
      provisions = { "com.example.app" => "/path/to/profile.mobileprovision" }
      expect(find_provision(provisions, "com.example.app")).to eq("/path/to/profile.mobileprovision")
    end

    it "returns empty string when no match" do
      provisions = { "com.example.app" => "/path/to/profile.mobileprovision" }
      expect(find_provision(provisions, "com.other.app")).to eq("")
    end

    it "wildcard provision matches any bundle ID" do
      provisions = { "*" => "/path/to/wildcard.mobileprovision" }
      expect(find_provision(provisions, "com.anything.here")).to eq("/path/to/wildcard.mobileprovision")
    end

    it "STRICT mode prevents wildcard match" do
      provisions = { "*" => "/path/to/wildcard.mobileprovision" }
      expect(find_provision(provisions, "com.anything.here", "STRICT")).to eq("")
    end

    it "returns first match when multiple provisions exist" do
      provisions = {
        "com.example.*" => "/path/to/first.mobileprovision",
        "com.example.app" => "/path/to/second.mobileprovision"
      }
      expect(find_provision(provisions, "com.example.app")).to eq("/path/to/first.mobileprovision")
    end
  end

  # ─── Group C: Bundle ID replacement sed ───────────────────────────────
  # resign.sh uses BSD sed's `-i .bak` syntax which only works on macOS
  describe "bundle ID replacement sed" do
    before(:each) do
      skip("BSD sed required (macOS only)") unless RUBY_PLATFORM.include?("darwin")
    end

    def run_sed_replacement(input_xml, old_id, new_id)
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, "entitlements.plist")
        File.write(file_path, input_xml)
        script = <<~BASH
          OLD_BUNDLE_ID="#{old_id}"
          NEW_BUNDLE_ID="#{new_id}"
          /usr/bin/sed -i .bak "s!${OLD_BUNDLE_ID}</string>!${NEW_BUNDLE_ID}</string>!g" "#{file_path}"
          cat "#{file_path}"
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true), "sed command failed"
        stdout
      end
    end

    it "replaces bundle ID before </string> tag" do
      input = "<string>AB1GP98Q19.com.old.app</string>"
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>AB1GP98Q19.com.new.app</string>")
    end

    it "replaces multiple occurrences" do
      input = <<~XML
        <string>TEAM.com.old.app</string>
        <string>group.com.old.app</string>
      XML
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>TEAM.com.new.app</string>")
      expect(result).to include("<string>group.com.new.app</string>")
    end

    it "only replaces before </string> tag, not </key>" do
      input = <<~XML
        <key>com.old.app</key>
        <string>TEAM.com.old.app</string>
      XML
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<key>com.old.app</key>")
      expect(result).to include("<string>TEAM.com.new.app</string>")
    end

    it "preserves team ID prefix" do
      input = "<string>TEAMIDPREF.com.old.app</string>"
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>TEAMIDPREF.com.new.app</string>")
    end

    it "replaces app group entries" do
      input = "<string>group.com.old.app</string>"
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>group.com.new.app</string>")
    end

    it "does not match partial IDs with extra suffix" do
      input = <<~XML
        <string>TEAM.com.old.app.extra</string>
        <string>TEAM.com.old.app</string>
      XML
      result = run_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>TEAM.com.old.app.extra</string>")
      expect(result).to include("<string>TEAM.com.new.app</string>")
    end

    it "handles multi-component bundle IDs" do
      input = "<string>TEAM.com.example.my.app</string>"
      result = run_sed_replacement(input, "com.example.my.app", "com.newco.other.app")
      expect(result.strip).to eq("<string>TEAM.com.newco.other.app</string>")
    end
  end

  # ─── Group D: Entitlements sed patterns ───────────────────────────────
  # These tests use BSD sed syntax from resign.sh which only runs on macOS
  describe "entitlements sed patterns" do
    before(:each) do
      skip("BSD sed required (macOS only)") unless RUBY_PLATFORM.include?("darwin")
    end

    describe "plist wrapper stripping" do
      it "extracts content between <plist> tags" do
        input = '<?xml version="1.0"?><plist version="1.0"><array><string>value</string></array></plist>'
        script = <<~BASH
          echo '#{input}' | tr -d '\\n' | /usr/bin/sed -e 's,.*<plist[^>]*>\\(.*\\)</plist>,\\1,g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("<array><string>value</string></array>")
      end

      it "handles plist with attributes" do
        input = '<?xml version="1.0"?><plist version="1.0"><dict><key>k</key></dict></plist>'
        script = <<~BASH
          echo '#{input}' | tr -d '\\n' | /usr/bin/sed -e 's,.*<plist[^>]*>\\(.*\\)</plist>,\\1,g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("<dict><key>k</key></dict>")
      end
    end

    describe "APP_ID replacement" do
      it "replaces old app ID with new app ID" do
        script = <<~BASH
          OLD_APP_ID="AB123.com.old.app"
          NEW_APP_ID="CD456.com.new.app"
          echo "<string>AB123.com.old.app</string>" | /usr/bin/sed -e "s/$OLD_APP_ID/$NEW_APP_ID/g"
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("<string>CD456.com.new.app</string>")
      end

      it "replaces multiple occurrences of app ID" do
        script = <<~BASH
          OLD_APP_ID="AB123.com.old.app"
          NEW_APP_ID="CD456.com.new.app"
          echo "<string>AB123.com.old.app</string><string>AB123.com.old.app</string>" | /usr/bin/sed -e "s/$OLD_APP_ID/$NEW_APP_ID/g"
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("<string>CD456.com.new.app</string><string>CD456.com.new.app</string>")
      end
    end

    describe "TEAM_ID replacement" do
      it "replaces old team ID with new team ID" do
        script = <<~BASH
          OLD_TEAM_ID="OLDTEAM123"
          NEW_TEAM_ID="NEWTEAM456"
          echo "<string>OLDTEAM123.com.example.app</string>" | /usr/bin/sed -e "s/$OLD_TEAM_ID/$NEW_TEAM_ID/g"
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("<string>NEWTEAM456.com.example.app</string>")
      end
    end

    describe "iCloud environment extraction" do
      it "extracts value from <string> tags" do
        script = <<~BASH
          echo "<string>Production</string>" | /usr/bin/sed -e 's,<string>\\(.*\\)</string>,\\1,g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("Production")
      end

      it "extracts Development environment" do
        script = <<~BASH
          echo "<string>Development</string>" | /usr/bin/sed -e 's,<string>\\(.*\\)</string>,\\1,g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq("Development")
      end
    end

    describe "dot escaping for plutil key paths" do
      it "escapes dots in key path" do
        script = <<~BASH
          echo "com.apple.security.application-groups" | /usr/bin/sed -e 's/\\./\\\\\\./g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq('com\.apple\.security\.application-groups')
      end

      it "does not escape hyphens" do
        script = <<~BASH
          echo "com.apple.developer.icloud-container-identifiers" | /usr/bin/sed -e 's/\\./\\\\\\./g'
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true)
        expect(stdout.strip).to eq('com\.apple\.developer\.icloud-container-identifiers')
      end
    end
  end

  # ─── Group E: Bundle ID replacement (current resign.sh implementation) ─
  # Tests the actual sed logic from resign.sh lines 859-862:
  #   1. Dots in bundle IDs are escaped to \. for sed
  #   2. sed regex anchors on <string> followed by a 10-char [A-Z0-9] team ID prefix
  # This group validates the PR #22058 fix and tests the actual sed commands
  # from resign.sh. The dot-escaping and sed lines are extracted from resign.sh
  # at runtime using grep, so changes to the implementation are automatically picked up.
  describe "bundle ID replacement (current implementation)" do
    before(:each) do
      skip("resign.sh not found") unless File.exist?(RESIGN_SH_PATH)
      skip("BSD sed required (macOS only)") unless RUBY_PLATFORM.include?("darwin")
    end

    # Runs the actual dot-escaping and sed replacement lines from resign.sh
    def run_current_sed_replacement(input_xml, old_id, new_id)
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, "entitlements.plist")
        File.write(file_path, input_xml)
        # Extract the dot-escaping and sed replacement lines directly from resign.sh.
        # This ensures tests always run the real implementation, not a copy.
        script = <<~BASH
          OLD_BUNDLE_ID="#{old_id}"
          NEW_BUNDLE_ID="#{new_id}"
          # Run the dot-escaping lines extracted from resign.sh
          eval "$(grep '_BUNDLE_ID=.*//\\.' "#{RESIGN_SH_PATH}")"
          # Run the sed replacement lines extracted from resign.sh
          eval "$(grep '/usr/bin/sed.*BUNDLE_ID' "#{RESIGN_SH_PATH}" | sed 's|"$PATCHED_ENTITLEMENTS"|"#{file_path}"|g')"
          cat "#{file_path}"
        BASH
        stdout, _, status = run_bash(script)
        expect(status.success?).to be(true), "sed command failed"
        stdout
      end
    end

    # --- Basic replacement with 10-char team ID prefix (PASS) ---

    it "replaces bundle ID in application-identifier entitlement" do
      input = "<string>AB1GP98Q19.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>AB1GP98Q19.com.new.app</string>")
    end

    it "preserves the original team ID prefix after replacement" do
      input = "<string>TEAMIDPREF.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>TEAMIDPREF.com.new.app</string>")
    end

    it "replaces multiple occurrences on separate lines" do
      input = <<~XML
        <string>ABCDE12345.com.old.app</string>
        <string>ABCDE12345.com.old.app</string>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.scan("ABCDE12345.com.new.app").length).to eq(2)
    end

    it "handles multi-component bundle IDs" do
      input = "<string>ABCDE12345.com.example.my.deep.app</string>"
      result = run_current_sed_replacement(input, "com.example.my.deep.app", "com.newco.other.app")
      expect(result.strip).to eq("<string>ABCDE12345.com.newco.other.app</string>")
    end

    it "does not replace inside <key> tags" do
      input = <<~XML
        <key>com.old.app</key>
        <string>ABCDE12345.com.old.app</string>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<key>com.old.app</key>")
      expect(result).to include("<string>ABCDE12345.com.new.app</string>")
    end

    # --- Dot escaping (PASS) ---

    it "treats dots as literal characters, not regex wildcards" do
      input = "<string>ABCDE12345.comXoldXapp</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>ABCDE12345.comXoldXapp</string>")
    end

    # --- The original substring collision bug - PR #22058 fix target (PASS) ---

    it "does not corrupt entitlements when old bundle ID is a substring of new bundle ID" do
      input = "<string>ABCDE12345.example.foo</string>"
      result = run_current_sed_replacement(input, "example.foo", "com.test.example.foo")
      expect(result.strip).to eq("<string>ABCDE12345.com.test.example.foo</string>")
    end

    # Exact scenario from PR #22058: entitlements already contain the new bundle ID
    # (com.test.example.foo) and old ID (example.foo) is a substring of it.
    # The old sed would find "example.foo" inside "com.test.example.foo" and produce
    # "com.test.com.test.example.foo" (duplicated segments), corrupting the entitlements.
    it "does not double-replace when entitlements already contain the new bundle ID" do
      input = "<string>AB1GP98Q19.com.test.example.foo</string>"
      result = run_current_sed_replacement(input, "example.foo", "com.test.example.foo")
      expect(result.strip).to eq("<string>AB1GP98Q19.com.test.example.foo</string>")
    end

    it "does not double-replace when new ID contains old ID" do
      input = "<string>ABCDE12345.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.old.app.extended")
      expect(result.strip).to eq("<string>ABCDE12345.com.old.app.extended</string>")
    end

    # --- Keychain access groups - uses team ID prefix (PASS) ---

    it "replaces bundle ID in keychain-access-groups entitlement" do
      input = <<~XML
        <key>keychain-access-groups</key>
        <array>
          <string>ABCDE12345.com.old.app</string>
        </array>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>ABCDE12345.com.new.app</string>")
    end

    it "does not replace keychain entry where old ID is only a prefix" do
      input = <<~XML
        <key>keychain-access-groups</key>
        <array>
          <string>ABCDE12345.com.old.app</string>
          <string>ABCDE12345.com.old.app.share</string>
        </array>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>ABCDE12345.com.new.app</string>")
      expect(result).to include("<string>ABCDE12345.com.old.app.share</string>")
    end

    # --- Different team ID formats (PASS) ---

    it "works with all-numeric team ID" do
      input = "<string>1234567890.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>1234567890.com.new.app</string>")
    end

    it "works with all-uppercase team ID" do
      input = "<string>ABCDEFGHIJ.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>ABCDEFGHIJ.com.new.app</string>")
    end

    it "works with mixed alphanumeric team ID" do
      input = "<string>A1B2C3D4E5.com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>A1B2C3D4E5.com.new.app</string>")
    end

    # --- REGRESSION: App Groups not replaced ("group" prefix != 10-char team ID) ---

    it "replaces bundle ID in app group entitlements" do
      input = <<~XML
        <key>com.apple.security.application-groups</key>
        <array>
          <string>group.com.old.app</string>
        </array>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>group.com.new.app</string>")
    end

    # --- REGRESSION: iCloud containers not replaced ("iCloud" prefix != 10-char team ID) ---

    it "replaces bundle ID in iCloud container identifiers" do
      input = <<~XML
        <key>com.apple.developer.icloud-container-identifiers</key>
        <array>
          <string>iCloud.com.old.app</string>
        </array>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>iCloud.com.new.app</string>")
    end

    it "replaces bundle ID in ubiquity-kvstore-identifier" do
      input = <<~XML
        <key>com.apple.developer.ubiquity-kvstore-identifier</key>
        <string>iCloud.com.old.app</string>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result).to include("<string>iCloud.com.new.app</string>")
    end

    # --- REGRESSION: Bare bundle ID without any prefix ---

    it "replaces bare bundle ID without prefix" do
      input = "<string>com.old.app</string>"
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")
      expect(result.strip).to eq("<string>com.new.app</string>")
    end

    # --- Full realistic entitlements plist ---

    it "replaces all bundle ID occurrences in a full entitlements plist" do
      input = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>application-identifier</key>
          <string>ABCDE12345.com.old.app</string>
          <key>keychain-access-groups</key>
          <array>
            <string>ABCDE12345.com.old.app</string>
          </array>
          <key>com.apple.security.application-groups</key>
          <array>
            <string>group.com.old.app</string>
          </array>
          <key>com.apple.developer.icloud-container-identifiers</key>
          <array>
            <string>iCloud.com.old.app</string>
          </array>
          <key>com.apple.developer.ubiquity-kvstore-identifier</key>
          <string>ABCDE12345.com.old.app</string>
          <key>aps-environment</key>
          <string>production</string>
        </dict>
        </plist>
      XML
      result = run_current_sed_replacement(input, "com.old.app", "com.new.app")

      # Team-ID-prefixed entries should be replaced
      expect(result).to include("<string>ABCDE12345.com.new.app</string>")
      expect(result).not_to include("<string>ABCDE12345.com.old.app</string>")

      # App group and iCloud entries should also be replaced
      expect(result).to include("<string>group.com.new.app</string>")
      expect(result).to include("<string>iCloud.com.new.app</string>")

      # aps-environment is unrelated and should be untouched
      expect(result).to include("<string>production</string>")
    end
  end
end
