require_relative '../internal/docs/plugin_scores'

describe Fastlane::Internal::Docs::PluginScores::FastlaneActionFileParser do
  describe 'parsing' do
    it "parses single line action's description" do
      action_file = './spec/fixtures/plugin_scores/single_line_description_action.rb'
      actions = Fastlane::Internal::Docs::PluginScores::FastlaneActionFileParser.new.parse_file(File.expand_path(action_file))
      expect(actions.length).to equal(1)
      expect(actions.first.description).to match('This is single line description.') if actions.length == 1
    end

    it "parses multi line action's description" do
      action_file = './spec/fixtures/plugin_scores/multi_line_description_action.rb'
      actions = Fastlane::Internal::Docs::PluginScores::FastlaneActionFileParser.new.parse_file(File.expand_path(action_file))
      expect(actions.length).to equal(1)
      expect(actions.first.description).to match('This is multi line description.') if actions.length == 1
    end
  end
end

describe Fastlane::Internal::Docs::PluginScores::FastlanePluginScore do
  describe ".github_page?" do
    it "accepts a github.com repository" do
      expect(described_class.github_page?("https://github.com/fastlane/fastlane")).to be(true)
    end

    it "rejects hosts that only start with github.com" do
      expect(described_class.github_page?("https://github.com.evil.example/fastlane/fastlane")).to be(false)
      expect(described_class.github_page?("https://github.company.example/fastlane/fastlane")).to be(false)
    end

    it "rejects non https and unparsable homepages" do
      expect(described_class.github_page?("http://github.com/fastlane/fastlane")).to be(false)
      expect(described_class.github_page?("not a url")).to be(false)
      expect(described_class.github_page?(nil)).to be(false)
    end
  end

  let(:api_url) { "https://api.github.com/repos/fastlane/fastlane-plugin-example" }

  def plugin_hash(overrides = {})
    {
      "name" => "fastlane-plugin-example",
      "downloads" => 0,
      "info" => "An example plugin",
      "homepage_uri" => "https://example.com/fastlane-plugin-example",
      "version" => "1.0.0",
      "licenses" => ["MIT"],
      "sha" => "abc123"
    }.merge(overrides)
  end

  def build_score(hash, cache: nil)
    Dir.mktmpdir("plugin-scores") do |tmp|
      cache_path = File.join(tmp, "cache.yml")
      File.write(cache_path, cache.to_yaml) if cache
      FastlaneSpec::Env.with_env_values("GITHUB_USER_NAME" => "user", "GITHUB_API_TOKEN" => "token") do
        yield(described_class.new(hash, cache_path), cache_path)
      end
    end
  end

  describe "#downloads_score" do
    it "gives 20 points per order of magnitude" do
      build_score(plugin_hash) do |score|
        expect(score.downloads_score(0)).to eq(0)
        expect(score.downloads_score(99)).to eq(40)
        expect(score.downloads_score(9_999)).to eq(80)
      end
    end

    it "caps the score at 100 points" do
      build_score(plugin_hash) do |score|
        expect(score.downloads_score(99_999)).to eq(100)
        expect(score.downloads_score(10_000_000)).to eq(100)
      end
    end

    it "treats negative and missing counts as zero" do
      build_score(plugin_hash) do |score|
        expect(score.downloads_score(-5)).to eq(0)
        expect(score.downloads_score(nil)).to eq(0)
      end
    end

    it "uses the gem's downloads for the downloads rating" do
      build_score(plugin_hash("downloads" => 999)) do |score|
        expect(score.data[:ratings][:downloads]).to eq(60)
      end
    end
  end

  describe "public GitHub repo rating" do
    it "does not rate a plugin without a GitHub homepage" do
      build_score(plugin_hash) do |score|
        expect(score.data[:public_github_repo]).to be_nil
        expect(score.data[:ratings][:public_github_repo]).to eq(0)
      end
    end

    context "with a cached GitHub plugin" do
      let(:hash) { plugin_hash("homepage_uri" => "https://github.com/fastlane/fastlane-plugin-example") }

      def cache_entry(extra = {})
        { "fastlane-plugin-example" => { sha: "abc123", cache_version: described_class::CACHE_VERSION, initial_commit: Date.new(2020, 1, 1) }.merge(extra) }
      end

      it "rewards a cached public repo" do
        build_score(hash, cache: cache_entry(public_github_repo: true)) do |score|
          expect(score.data[:public_github_repo]).to be(true)
          expect(score.data[:ratings][:public_github_repo]).to eq(20)
        end
      end

      it "penalizes a cached private or missing repo" do
        build_score(hash, cache: cache_entry(public_github_repo: false)) do |score|
          expect(score.data[:ratings][:public_github_repo]).to eq(-50)
        end
      end

      it "refetches a plugin cached by an older cache version" do
        expect_any_instance_of(described_class).to receive(:append_git_data)
        expect_any_instance_of(described_class).to receive(:append_github_data)

        build_score(hash, cache: cache_entry(cache_version: nil, public_github_repo: false)) { |score| }
      end

      it "refetches a plugin cached before cache versions existed" do
        old_entry = cache_entry
        old_entry["fastlane-plugin-example"].delete(:cache_version)
        expect_any_instance_of(described_class).to receive(:append_git_data)
        expect_any_instance_of(described_class).to receive(:append_github_data)

        build_score(hash, cache: old_entry) { |score| }
      end
    end

    describe "#append_github_data" do
      def fetch_github_data
        build_score(plugin_hash) do |score|
          score.homepage = "https://github.com/fastlane/fastlane-plugin-example/"
          score.cache[score.name] = { cache_version: described_class::CACHE_VERSION }
          allow(score).to receive(:puts)
          allow(score).to receive(:sleep)
          score.append_github_data
          yield(score)
        end
      end

      def stub_repo(private:)
        stub_request(:get, api_url).to_return(status: 200, body: { "private" => private, "stargazers_count" => 7 }.to_json)
      end

      it "marks a public repo" do
        stub_repo(private: false)
        stub_request(:get, "#{api_url}/stats/contributors").to_return(status: 200, body: [{}, {}].to_json)

        fetch_github_data do |score|
          expect(score.data[:public_github_repo]).to be(true)
          expect(score.cache[score.name][:public_github_repo]).to be(true)
          expect(score.data[:github_stars]).to eq(7)
          expect(score.data[:github_contributors]).to eq(2)
        end
      end

      it "marks a private repo as not public" do
        stub_repo(private: true)
        stub_request(:get, "#{api_url}/stats/contributors").to_return(status: 200, body: [].to_json)

        fetch_github_data do |score|
          expect(score.data[:public_github_repo]).to be(false)
          expect(score.cache[score.name][:public_github_repo]).to be(false)
        end
      end

      it "marks a missing repo as not public" do
        stub_request(:get, api_url).to_return(status: 404, body: { "message" => "Not Found" }.to_json)

        fetch_github_data do |score|
          expect(score.data[:public_github_repo]).to be(false)
          expect(a_request(:get, "#{api_url}/stats/contributors")).not_to have_been_made
        end
      end

      it "raises instead of caching a rate limited response" do
        stub_request(:get, api_url).to_return(status: 403, body: { "message" => "API rate limit exceeded" }.to_json)

        expect { fetch_github_data { |score| } }.to raise_error(/GitHub returned 403/)
      end

      it "raises when contributor stats fail" do
        stub_repo(private: false)
        stub_request(:get, "#{api_url}/stats/contributors").to_return(status: 403, body: "{}")

        expect { fetch_github_data { |score| } }.to raise_error(/GitHub returned 403/)
      end

      it "polls contributor stats while GitHub returns 202" do
        stub_repo(private: false)
        stub_request(:get, "#{api_url}/stats/contributors").
          to_return({ status: 202, body: "{}" }, { status: 202, body: "{}" }, { status: 200, body: [{}, {}, {}].to_json })

        fetch_github_data do |score|
          expect(score).to have_received(:sleep).with(10).twice
          expect(score.data[:github_contributors]).to eq(3)
          expect(score.cache[score.name][:cache_version]).to eq(described_class::CACHE_VERSION)
        end
      end

      it "counts no contributors and refetches next run when the stats never become ready" do
        stub_repo(private: false)
        stub_request(:get, "#{api_url}/stats/contributors").to_return(status: 202, body: "{}")

        fetch_github_data do |score|
          expect(score).to have_received(:sleep).exactly(12).times
          expect(score.data[:github_contributors]).to eq(0)
          expect(score.cache[score.name]).not_to have_key(:cache_version)
        end
      end
    end
  end
end
