describe Spaceship::ConnectAPI::AppCustomProductPage do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(mock_tunes_client).to receive(:select_team)
    allow(mock_tunes_client).to receive(:csrf_tokens)
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: false, use_tunes: true)
  end

  it 'gets a custom product page with its app' do
    ConnectAPIStubbing::Tunes.stub_get_app_custom_product_page

    page = Spaceship::ConnectAPI::AppCustomProductPage.get(app_custom_product_page_id: "cpp-123", includes: "app").first
    expect(page).to be_an_instance_of(Spaceship::ConnectAPI::AppCustomProductPage)
    expect(page.id).to eq("cpp-123")
    expect(page.name).to eq("Tarot")
    expect(page.visible).to eq(true)
    expect(page.url).to eq("https://apps.apple.com/us/app/id123456789?ppid=cpp-123")
    expect(page.app).to be_an_instance_of(Spaceship::ConnectAPI::App)
    expect(page.app.id).to eq("123456789")
  end

  it 'gets the versions of a custom product page' do
    ConnectAPIStubbing::Tunes.stub_get_app_custom_product_page_versions

    versions = Spaceship::ConnectAPI::AppCustomProductPageVersion.all(app_custom_product_page_id: "cpp-123")
    expect(versions.map(&:id)).to eq(["cpp-version-1", "cpp-version-2"])
    expect(versions.map(&:version)).to eq(["1", "2"])
    expect(versions.map(&:state)).to eq([
                                          Spaceship::ConnectAPI::AppCustomProductPageVersion::State::APPROVED,
                                          Spaceship::ConnectAPI::AppCustomProductPageVersion::State::PREPARE_FOR_SUBMISSION
                                        ])
    expect(versions.last.deep_link).to eq("example://tarot")
    expect(versions.map(&:editable?)).to eq([false, true])
  end
end
