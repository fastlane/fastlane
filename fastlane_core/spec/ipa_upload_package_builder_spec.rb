describe FastlaneCore do
  describe FastlaneCore::IpaUploadPackageBuilder do
    let(:ipa) { 'iOSAppOnly' }
    let(:path) { File.expand_path("../fixtures/ipas/#{ipa}.ipa", __FILE__) }
    let(:uploader) { FastlaneCore::IpaUploadPackageBuilder.new }
    let(:unique_path) { uploader.unique_ipa_path(path) }

    def special_chars?(string)
      string =~ /^[A-Za-z0-9_\.]+$/ ? false : true
    end

    context 'special_chars?' do
      it 'returns false for and zero special characters and emoji' do
        is_valid = special_chars?("something_IPA_1234567890.ipa")
        expect(is_valid).to be(false)
      end

      it 'returns true for all special characters' do
        special_chars = %w[! @ # $ % ^ & * ( ) + = [ ] " ' ; : < > ? / \ | { } , ~ `]

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
    end
  end
end
