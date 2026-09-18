describe Trainer do
  describe Trainer::XCResult::Helper do
    def stub_version_output(output)
      allow(Trainer::XCResult::Helper).to receive(:`).with('xcrun xcresulttool version').and_return(output)
    end

    describe "#xcresulttool_version" do
      it 'reads the version out of what xcresulttool reports' do
        stub_version_output('xcresulttool version 23021, format version 3.53 (current)')
        expect(Trainer::XCResult::Helper.xcresulttool_version).to eq(Gem::Version.new(23_021))
      end

      it 'reads the version from the newer banner shape' do
        stub_version_output('xcresulttool version 24408, schema version: 0.1.0 (legacy commands format version: 3.56)')
        expect(Trainer::XCResult::Helper.xcresulttool_version).to eq(Gem::Version.new(24_408))
      end

      it 'returns nil when there is no xcrun to ask' do
        allow(Trainer::XCResult::Helper).to receive(:`).with('xcrun xcresulttool version').and_raise(Errno::ENOENT)
        expect(Trainer::XCResult::Helper.xcresulttool_version).to be_nil
      end

      it 'raises when the output cannot be read, rather than reporting no support' do
        stub_version_output("xcrun: error: unable to find utility \"xcresulttool\"\n")
        expect do
          Trainer::XCResult::Helper.xcresulttool_version
        end.to raise_error(/Could not read the xcresulttool version from/)
      end

      it 'raises when the output is empty' do
        stub_version_output('')
        expect { Trainer::XCResult::Helper.xcresulttool_version }.to raise_error(/Could not read the xcresulttool version/)
      end
    end

    describe "#supports_xcresulttool_version_23?" do
      it 'is true from 23021 onwards' do
        stub_version_output('xcresulttool version 23021, format version 3.53 (current)')
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_23?).to be(true)
      end

      it 'is true for a newer major version' do
        stub_version_output('xcresulttool version 24408, schema version: 0.1.0')
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_23?).to be(true)
      end

      it 'is false for an older version' do
        stub_version_output('xcresulttool version 22608, format version 3.49 (current)')
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_23?).to be(false)
      end

      it 'is false when there is no xcrun to ask' do
        allow(Trainer::XCResult::Helper).to receive(:`).with('xcrun xcresulttool version').and_raise(Errno::ENOENT)
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_23?).to be(false)
      end

      it 'raises when the version cannot be read, rather than reporting no support' do
        stub_version_output("xcrun: error: unable to find utility \"xcresulttool\"\n")
        expect do
          Trainer::XCResult::Helper.supports_xcresulttool_version_23?
        end.to raise_error(/Could not read the xcresulttool version/)
      end
    end

    describe "#supports_xcresulttool_version_24?" do
      it 'is true from 24408 onwards' do
        stub_version_output('xcresulttool version 24408, schema version: 0.1.0')
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_24?).to be(true)
      end

      it 'is false for version 23' do
        stub_version_output('xcresulttool version 23021, format version 3.53 (current)')
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_24?).to be(false)
      end

      it 'is false when there is no xcrun to ask' do
        allow(Trainer::XCResult::Helper).to receive(:`).with('xcrun xcresulttool version').and_raise(Errno::ENOENT)
        expect(Trainer::XCResult::Helper.supports_xcresulttool_version_24?).to be(false)
      end

      it 'raises when the version cannot be read, rather than reporting no support' do
        stub_version_output("xcrun: error: unable to find utility \"xcresulttool\"\n")
        expect do
          Trainer::XCResult::Helper.supports_xcresulttool_version_24?
        end.to raise_error(/Could not read the xcresulttool version/)
      end
    end
  end
end
