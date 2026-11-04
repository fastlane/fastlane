require 'fastlane/fastlane_require'

describe Fastlane do
  describe Fastlane::FastlaneRequire do
    it "formats gem require name for fastlane-plugin" do
      gem_name = "fastlane-plugin-test"
      gem_require_name = Fastlane::FastlaneRequire.format_gem_require_name(gem_name)
      expect(gem_require_name).to eq("fastlane/plugin/test")
    end

    it "formats gem require name for non-fastlane-plugin" do
      gem_name = "some-lib"
      gem_require_name = Fastlane::FastlaneRequire.format_gem_require_name(gem_name)
      expect(gem_require_name).to eq("some-lib")
    end

    describe "checks if a gem is installed" do
      it "true on known installed gem" do
        gem_name = "fastlane"
        gem_installed = Fastlane::FastlaneRequire.gem_installed?(gem_name)
        expect(gem_installed).to be(true)
      end

      it "false on known missing gem" do
        gem_name = "foobar"
        gem_installed = Fastlane::FastlaneRequire.gem_installed?(gem_name)
        expect(gem_installed).to be(false)
      end

      it "true on known preinstalled gem" do
        gem_name = "yaml"
        gem_installed = Fastlane::FastlaneRequire.gem_installed?(gem_name)
        expect(gem_installed).to be(true)
      end
    end

    describe "installs a missing gem" do
      let(:fetcher) { instance_double(Gem::SpecFetcher, detect: [], suggest_gems_from_name: suggestions) }
      let(:installer) { double("installer") }

      before do
        require "rubygems/command_manager"
        allow(Fastlane::FastlaneRequire).to receive(:install_gem_if_needed).and_call_original
        allow(Fastlane::FastlaneRequire).to receive(:gem_installed?).and_return(false)
        allow(Fastlane::Helper).to receive(:bundler?).and_return(false)
        # Take the branch that installs, which tests otherwise return before
        allow(Fastlane::Helper).to receive(:test?).and_return(false)
        allow(Gem::SpecFetcher).to receive(:fetcher).and_return(fetcher)
        allow(Gem::CommandManager.instance).to receive(:[]).with(:install).and_return(installer)
      end

      context "when RubyGems only has a similar name" do
        let(:suggestions) { ["fastlane-plugin-similar"] }

        it "stops and suggests that name instead of installing it" do
          expect(installer).not_to receive(:install_gem)

          expect do
            Fastlane::FastlaneRequire.install_gem_if_needed(gem_name: "fastlane-plugin-asked", require_gem: true)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find gem 'fastlane-plugin-asked' on RubyGems. Did you mean 'fastlane-plugin-similar'? Fix the name in your Fastfile")
        end
      end

      context "when RubyGems has no similar name" do
        let(:suggestions) { [] }

        it "stops and names the missing gem" do
          expect(installer).not_to receive(:install_gem)

          expect do
            Fastlane::FastlaneRequire.install_gem_if_needed(gem_name: "fastlane-plugin-asked", require_gem: true)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find gem 'fastlane-plugin-asked' on RubyGems")
        end
      end
    end
  end
end
