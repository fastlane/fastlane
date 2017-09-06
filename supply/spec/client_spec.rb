describe Supply do
  describe Supply::Client do
    describe "AndroidPublisher" do
      let(:subject) { Androidpublisher::AndroidPublisherService.new }

      # Verify that the Google API client has all the expected methods we use.
      it "has all the expected Google API methods" do
        expect(subject.class.method_defined?(:commit_edit)).to eq(true)
        expect(subject.class.method_defined?(:delete_edit)).to eq(true)
        expect(subject.class.method_defined?(:delete_all_images)).to eq(true)
        expect(subject.class.method_defined?(:get_listing)).to eq(true)
        expect(subject.class.method_defined?(:get_track)).to eq(true)
        expect(subject.class.method_defined?(:insert_edit)).to eq(true)
        expect(subject.class.method_defined?(:list_apk_listings)).to eq(true)
        expect(subject.class.method_defined?(:list_apks)).to eq(true)
        expect(subject.class.method_defined?(:list_images)).to eq(true)
        expect(subject.class.method_defined?(:list_listings)).to eq(true)
        expect(subject.class.method_defined?(:update_apk_listing)).to eq(true)
        expect(subject.class.method_defined?(:update_listing)).to eq(true)
        expect(subject.class.method_defined?(:update_track)).to eq(true)
        expect(subject.class.method_defined?(:upload_apk)).to eq(true)
        expect(subject.class.method_defined?(:upload_edit_deobfuscationfile)).to eq(true)
        expect(subject.class.method_defined?(:upload_expansion_file)).to eq(true)
        expect(subject.class.method_defined?(:upload_image)).to eq(true)
        expect(subject.class.method_defined?(:validate_edit)).to eq(true)
      end
    end
  end
end
