describe Fastlane do
  describe Fastlane::Runner do
    describe "#available_lanes" do
      before do
        @ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "lists all available lanes" do
        expect(@ff.runner.available_lanes).to eq(["test", "anotherroot", "mac beta", "ios beta", "ios release", "android beta", "android witherror", "android unsupported_action"])
      end

      it "allows filtering of results" do
        expect(@ff.runner.available_lanes('android')).to eq(["android beta", "android witherror", "android unsupported_action"])
      end

      it "returns an empty array if invalid input is given" do
        expect(@ff.runner.available_lanes('asdfasdfasdf')).to eq([])
      end

      it "doesn't show private lanes" do
        expect(@ff.runner.available_lanes).to_not(include('android such_private'))
      end

      describe "step_name override" do
        it "handle overriding of step_name" do
          allow(Fastlane::Actions).to receive(:execute_action).with('Let it Frame')
          @ff.runner.execute_action(:frameit, Fastlane::Actions::FrameitAction, [{ step_name: "Let it Frame" }])
        end
        it "rely on step_text when no step_name given" do
          allow(Fastlane::Actions).to receive(:execute_action).with('frameit')

          @ff.runner.execute_action(:frameit, Fastlane::Actions::FrameitAction, [{}])
        end
      end
    end

    describe "#execute" do
      before do
        @ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileLaneKeywordParams')
      end

      context 'when a lane does not expect any parameter' do
        it 'accepts calling the lane with no parameter' do
          result = @ff.runner.execute(:lane_no_param, :ios)
          expect(result).to eq('No parameter')
        end

        it 'accepts calling the lane with arbitrary (unused) parameter' do
          result = @ff.runner.execute(:lane_no_param, :ios, { unused1: 42, unused2: true })
          expect(result).to eq('No parameter')
        end
      end

      context 'when a lane expects its parameters as a Hash' do
        it 'accepts calling the lane with no parameter at all' do
          result = @ff.runner.execute(:lane_hash_param, :ios)
          expect(result).to eq('name: nil; version: nil; interactive: nil')
        end

        it 'accepts calling the lane with less parameters than used by the lane' do
          result = @ff.runner.execute(:lane_hash_param, :ios, { version: '12.3' })
          expect(result).to eq('name: nil; version: "12.3"; interactive: nil')
        end

        it 'accepts calling the lane with more parameters than used by the lane' do
          result = @ff.runner.execute(:lane_hash_param, :ios, { name: 'test', version: '12.3', interactive: true, unused: 42 })
          expect(result).to eq('name: "test"; version: "12.3"; interactive: true')
        end
      end


      context 'when a lane expects its parameters as keywords' do
        it 'fails when calling the lane with no parameter at all' do
          expect do
            @ff.runner.execute(:lane_kw_params, :ios)
          end.to raise_error(ArgumentError, 'missing keywords: :name, :version')
        end

        it 'fails when calling the lane with missing parameters' do
          expect do
            @ff.runner.execute(:lane_kw_params, :ios, { name: 'test', interactive: true })
          end.to raise_error(ArgumentError, 'missing keyword: :version')
        end

        it 'fails when calling the lane with extra parameters' do
          expect do
            @ff.runner.execute(:lane_kw_params, :ios, { name: 'test', version: '12.3', interactive: true, unexpected: 42 })
          end.to raise_error(ArgumentError, 'unknown keyword: :unexpected')
        end

        it 'takes all parameters into account when all are passed explicitly' do
          result = @ff.runner.execute(:lane_kw_params, :ios, { name: 'test', version: "12.3", interactive: true })
          expect(result).to eq('name: "test"; version: "12.3"; interactive: true')
        end

        it 'use default values of parameters not provided explicitly' do
          result = @ff.runner.execute(:lane_kw_params, :ios, { name: 'test', version: "12.3" })
          expect(result).to eq('name: "test"; version: "12.3"; interactive: true')
        end

        it 'allows parameters to be provided in arbitrary order' do
          result = @ff.runner.execute(:lane_kw_params, :ios, { version: "12.3", name: 'test', interactive: true })
          expect(result).to eq('name: "test"; version: "12.3"; interactive: true')
        end
      end
    end
  end
end
