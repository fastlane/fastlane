describe Deliver do
  describe Deliver::DeliverProcess do

    describe "fetch information from ipa file" do

      before(:each) do
        @version = '1.0'
        @identifier = 'at.felixkrause.iTanky'
        @ipa = "spec/fixtures/ipas/Example1.ipa"
      end

      context "when there's a beta build defined" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: true,
            beta_ipa: beta_ipa,
            skip_deploy: false,
          })

          @process.fetch_information_from_ipa_file
        end

        it "uploads a beta build" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_BETA_BUILD
        end
      end

      context "when there's no beta build defined" do

        before(:each) do
          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: false,
            skip_deploy: false,
            ipa: @ipa
          })

          @process.fetch_information_from_ipa_file
        end

        it "uploads a build to the app store" do
          expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_APP_STORE
        end
      end

      context "when there's no beta build defined but deployment should be skipped" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: false,
            ipa: @ipa,
            skip_deploy: true,
          })

          @process.fetch_information_from_ipa_file
        end

        it "skips deployment" do
            expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
        end
      end

      context "when there's a beta build defined but deployment should be skipped" do
        before(:each) do
          beta_ipa = "spec/fixtures/ipas/Example2.ipa"

          @process = Deliver::DeliverProcess.new({
            app_identifier: @identifier,
            version: @version,
            is_beta_ipa: true,
            beta_ipa: beta_ipa,
            skip_deploy: true,
          })

          @process.fetch_information_from_ipa_file
        end

        it "skips deployment" do
            expect(@process.ipa.publish_strategy).to eq Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
        end
      end
    end
  end
end
