describe FastlaneCore do
  describe FastlaneCore::IpaUploadPackageBuilder do
    let(:ipa) { 'iOSAppOnly' }
    let(:path) { File.expand_path("../fixtures/ipas/#{ipa}.ipa", __FILE__) }
    let(:uploader) { FastlaneCore::IpaUploadPackageBuilder.new }
    let(:unique_path) { uploader.unique_ipa_path(path) }

    let(:ipa_with_spaces) { 'iOS App With Spaces' }
    let(:path_with_spaces) { File.expand_path("../fixtures/ipas/#{ipa_with_spaces}.ipa", __FILE__) }
    let(:unique_path_with_spaces) { uploader.unique_ipa_path(path_with_spaces) }

    def special_chars?(string)
      string =~ /^[A-Za-z0-9_\.]+$/ ? false : true
    end

    context 'special_chars?' do
      it 'returns false for and zero special characters and emoji' do
        is_valid = special_chars?("something_IPA_1234567890.ipa")
        expect(is_valid).to be(false)
      end

      it 'returns true for all special characters' do
        special_chars = %w[! @ # $ % ^ & * ( ) + = [ ] " ' ; : < > ? / \\ | { } , ~ `]

        special_chars.each do |c|
          is_valid = special_chars?("something_#{c}.ipa")
          expect(is_valid).to be(true)
        end
      end

      it 'returns true for emoji' do
        is_valid = special_chars?("something_😝_🚀.ipa")
        expect(is_valid).to be(true)
      end
    end

    context 'unique IPA file name' do
      it 'does not contain any special characters' do
        is_valid = !special_chars?(unique_path)
        expect(is_valid).to be(true)
      end

      it 'does not start with allowed special characters' do
        okay_chars = %w[- . _]

        okay_chars.each do |okay_char|
          expect(unique_path).not_to(start_with(okay_char))
        end
      end

      it 'does not contain any spaces' do
        expect(unique_path_with_spaces.include?(' ')).to eq(false)
      end
    end

    context '#generate' do
      let(:app_id) { 'my.app.id' }

      # `package_path` is a *parent* directory that the caller may share with unrelated files —
      # `deliver` passes "/tmp". ItunesTransporter#upload does `FileUtils.rm_rf` on whatever
      # `generate` returns, so returning the parent itself would delete it along with everything
      # else in it, and would make the transporter's `Dir.glob` match foreign packages.
      around do |example|
        Dir.mktmpdir do |parent|
          @parent = parent
          example.run
        end
      end

      def generate(source_ipa: path)
        FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: app_id,
          ipa_path: source_ipa,
          package_path: @parent,
          platform: 'ios'
        )
      end

      shared_examples 'a package contained in package_path' do
        it 'does not return package_path itself' do
          expect(generate).not_to eq(@parent)
        end

        it 'returns a new directory directly below package_path' do
          result = generate

          expect(File.dirname(result)).to eq(@parent)
          expect(File.directory?(result)).to be(true)
        end

        it 'leaves package_path intact when the returned path is removed' do
          sibling = File.join(@parent, 'unrelated.ipa')
          File.write(sibling, 'not ours')

          FileUtils.rm_rf(generate)

          expect(File.directory?(@parent)).to be(true)
          expect(File.exist?(sibling)).to be(true)
        end

        it 'uses a distinct directory for each invocation' do
          expect(generate).not_to eq(generate)
        end

        it 'places exactly one package file inside the returned directory' do
          result = generate

          expect(Dir.glob(File.join(result, '*.ipa')).count).to eq(1)
        end
      end

      context 'on macOS' do
        before do
          allow(FastlaneCore::Helper).to receive(:is_mac?).and_return(true)
        end

        it_behaves_like 'a package contained in package_path'

        it 'builds an .itmsp package' do
          expect(generate).to end_with('.itmsp')
        end
      end

      context 'on non-macOS platforms' do
        before do
          allow(FastlaneCore::Helper).to receive(:is_mac?).and_return(false)
        end

        it_behaves_like 'a package contained in package_path'

        it 'copies an adjacent AppStoreInfo.plist into the package' do
          Dir.mktmpdir do |source|
            source_ipa = File.join(source, 'MyApp.ipa')
            FileUtils.cp(path, source_ipa)
            File.write(File.join(source, 'AppStoreInfo.plist'), '<plist></plist>')

            result = generate(source_ipa: source_ipa)

            expect(File.file?(File.join(result, 'AppStoreInfo.plist'))).to be(true)
          end
        end
      end
    end
  end
end
