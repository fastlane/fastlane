describe Spaceship::ConnectAPI::Client do
  let(:client) { Spaceship::ConnectAPI::TestFlight::Client.instance }
  let(:hostname) { Spaceship::ConnectAPI::Users::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::Tunes.login(username, password)
  end

  context 'build_params' do
    let(:path) { "betaAppReviewDetails" }
    let(:nil_filter) { { build: nil } }
    let(:one_filter) { { build: "123" } }
    let(:two_filters) { { build: "123", app: "321" } }
    let(:includes) { "model.attribute" }
    let(:limit) { "30" }
    let(:sort) { "asc" }

    it 'builds params with nothing' do
      params = client.build_params
      expect(params).to eq({})
    end

    it 'builds params with nil filter' do
      params = client.build_params(filter: nil_filter)
      expect(params).to eq({})
    end

    it 'builds params with one filter' do
      params = client.build_params(filter: one_filter)
      expect(params).to eq({
        filter: one_filter
      })
    end

    it 'builds params with two filters' do
      params = client.build_params(filter: two_filters)
      expect(params).to eq({
        filter: two_filters
      })
    end

    it 'builds params with includes' do
      params = client.build_params(includes: includes)
      expect(params).to eq({
        include: includes
      })
    end

    it 'builds params with limit' do
      params = client.build_params(limit: limit)
      expect(params).to eq({
        limit: limit
      })
    end

    it 'builds params with sort' do
      params = client.build_params(sort: sort)
      expect(params).to eq({
        sort: sort
      })
    end

    it 'builds params with one filter, includes, limit, and sort' do
      params = client.build_params(filter: one_filter, includes: includes, limit: limit, sort: sort)
      expect(params).to eq({
        filter: one_filter,
        include: includes,
        limit: limit,
        sort: sort
      })
    end
  end
end
