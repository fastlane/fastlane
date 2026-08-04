describe Spaceship::ConnectAPI::Webhook do
  before do
    token = Spaceship::ConnectAPI::Token.from_json_file(File.expand_path("../fixtures/asc_key.json", __dir__))
    Spaceship::ConnectAPI.token = token
  end

  after do
    Spaceship::ConnectAPI.token = nil
  end

  describe '#client' do
    describe '#get_webhooks' do
      it 'returns all webhooks for an app' do
        response = Spaceship::ConnectAPI.get_webhooks(app_id: "123456789")
        expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

        expect(response.count).to eq(2)
        response.each do |model|
          expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Webhook)
        end

        model = response.first
        expect(model.id).to eq("webhook-123")
        expect(model.name).to eq("Production Webhook")
        expect(model.url).to eq("https://example.com/webhook")
        expect(model.enabled).to eq(true)
        expect(model.event_types).to eq(["APP_STORE_VERSION_APP_VERSION_STATE_UPDATED"])
      end

      it 'deserializes second webhook correctly' do
        response = Spaceship::ConnectAPI.get_webhooks(app_id: "123456789")
        model = response.to_a[1]
        expect(model.id).to eq("webhook-456")
        expect(model.name).to eq("Staging Webhook")
        expect(model.url).to eq("https://staging.example.com/webhook")
        expect(model.enabled).to eq(true)
      end
    end

    it '#post_webhook' do
      response = Spaceship::ConnectAPI.post_webhook(
        app_id: "123456789",
        enabled: true,
        event_types: ["BUILD_UPLOAD_STATE_UPDATED"],
        name: "New Webhook",
        secret: "my-secret",
        url: "https://new.example.com/webhook"
      )
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Webhook)
      expect(model.id).to eq("webhook-789")
      expect(model.name).to eq("New Webhook")
      expect(model.url).to eq("https://new.example.com/webhook")
      expect(model.enabled).to eq(true)
    end

    it '#delete_webhook' do
      response = Spaceship::ConnectAPI.delete_webhook(webhook_id: "webhook-123")
      expect(response).to be_nil.or(be_an_instance_of(Spaceship::ConnectAPI::Response))
    end
  end

  it '.all' do
    webhooks = Spaceship::ConnectAPI::Webhook.all(app_id: "123456789")
    expect(webhooks).to be_an_instance_of(Array)
    expect(webhooks.length).to eq(2)
    webhooks.each do |webhook|
      expect(webhook).to be_an_instance_of(Spaceship::ConnectAPI::Webhook)
    end
  end

  it '.create' do
    webhook = Spaceship::ConnectAPI::Webhook.create(
      app_id: "123456789",
      event_types: ["BUILD_UPLOAD_STATE_UPDATED"],
      name: "New Webhook",
      secret: "my-secret",
      url: "https://new.example.com/webhook"
    )
    expect(webhook).to be_an_instance_of(Spaceship::ConnectAPI::Webhook)
    expect(webhook.name).to eq("New Webhook")
    expect(webhook.url).to eq("https://new.example.com/webhook")
  end
end
