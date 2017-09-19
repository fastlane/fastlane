describe FastlaneCore do
  describe FastlaneCore::IpaUploadPackageBuilder do
    let(:ipa) { 'iOSAppOnly' }
    let(:path) { File.expand_path("../fixtures/ipas/#{ipa}.ipa", __FILE__) }
    let(:uploader) { FastlaneCore::IpaUploadPackageBuilder.new }
    let(:unique_path) { uploader.unique_ipa_path(path) }

    context 'unique IPA file name' do
      it 'does not contain any special characters' do
        special_chars = %w[! @ # $ % ^ & * ( ) + = [ ] " ' ; : < > ? / \ | { } , ~ `]

        special_chars.each do |special_char|
          expect(unique_path).not_to include(special_char)
        end
      end

      it 'does not start with allowed special characters' do
        okay_chars = %w[- . _]

        okay_chars.each do |okay_char|
          expect(unique_path).not_to start_with(okay_char)
        end
      end
    end
  end
end