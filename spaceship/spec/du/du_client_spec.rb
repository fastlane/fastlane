describe Spaceship::DUClient, :du do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppVersion.client }
  let(:app) { Spaceship::Application.all.first }
  let(:contentProviderId) { "1234567" }
  let(:ssoTokenForImage) { "sso token for image" }
  let(:version) { app.edit_version }

  subject { Spaceship::DUClient.new }

  before do
    allow(Spaceship::Utilities).to receive(:md5digest).and_return("FAKEMD5")
  end

  describe "#upload_large_icon and #upload_watch_icon" do
    let(:correct_jpg_image) { du_uploadimage_correct_jpg }
    let(:bad_png_image) { du_uploadimage_invalid_png }

    it "handles successful upload request using #upload_large_icon" do
      du_upload_large_image_success

      data = subject.upload_large_icon(version, correct_jpg_image, contentProviderId, ssoTokenForImage)
      expect(data['token']).to eq('Purple7/v4/65/04/4d/65044dae-15b0-a5e0-d021-5aa4162a03a3/pr_source.jpg')
    end

    it "handles failed upload request using #upload_watch_icon" do
      du_upload_watch_image_failure

      error_text = "[IMG_ALPHA_NOT_ALLOWED] Alpha is not allowed. Please edit the image to remove alpha and re-save it."
      expect do
        data = subject.upload_watch_icon(version, bad_png_image, contentProviderId, ssoTokenForImage)
      end.to raise_error(Spaceship::Client::UnexpectedResponse, error_text)
    end
  end

  describe "#upload_geojson" do
    let(:valid_geojson) { du_upload_valid_geojson }
    let(:invalid_geojson) { du_upload_invalid_geojson }

    it "handles successful upload request" do
      du_upload_geojson_success

      data = subject.upload_geojson(version, valid_geojson, contentProviderId, ssoTokenForImage)
      expect(data['token']).to eq('Purple1/v4/45/50/9d/45509d39-6a5d-7f55-f919-0fbc7436be61/pr_source.geojson')
      expect(data['dsId']).to eq(1_206_675_732)
      expect(data['type']).to eq('SMGameCenterAvatarImageType.SOURCE')
    end

    it "handles failed upload request" do
      du_upload_geojson_failure

      error_text = "[FILE_GEOJSON_FIELD_NOT_SUPPORTED] The routing app coverage file is in the wrong format. For more information, see the Location and Maps Programming Guide in the iOS Developer Library."
      expect do
        data = subject.upload_geojson(version, invalid_geojson, contentProviderId, ssoTokenForImage)
      end.to raise_error(Spaceship::Client::UnexpectedResponse, error_text)
    end
  end

  describe "#upload_screenshot" do
    # we voluntary skip tests for this method, it's mostly covered by other functions
  end
end
