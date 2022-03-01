describe Fastlane do
  describe Fastlane::FastFile do
    describe 'App Store Connect API Token' do
      TEST_KEY_ID = 'BA5176BF04'
      TEST_ISSUER_ID = '693fbb20-54a0-4d94-88ce-8a6caf875439'

      @expected_in_house = nil
      @test_command = nil

      let(:test_private_key) { OpenSSL::PKey::EC.new('prime256v1').generate_key }
      let(:test_iat) { Time.now.to_i }
      let(:test_exp) { test_iat + 20 * 60 }
      let(:test_token_jwt_text) do
        JWT.encode(
          {
            iss: TEST_ISSUER_ID,
            iat: test_iat,
            exp: test_exp,
            aud: "appstoreconnect-v1"
          },
          test_private_key,
          "ES256",
          header_fields = {
            alg: 'ES256',
            typ: 'JWT',
            kid: TEST_KEY_ID
          }
        )
      end
      let(:test_token_jwt_filepath) { Dir::Tmpname.create(%w[asc_token .jwt]) {} }
      let(:expected_hash) do
        { in_house: @expected_in_house, token_text: test_token_jwt_text }
      end
      let(:test_lane_execution) do
        test_lane = "lane :test do
                       #{@test_command}
                     end"

        Fastlane::FastFile.new.parse(test_lane).runner.execute(:test)
      end

      before(:each) do
        Fastlane::Actions.clear_lane_context
        Spaceship::ConnectAPI.token = nil
      end

      after(:each) do
        Fastlane::Actions.clear_lane_context
        Spaceship::ConnectAPI.token = nil
      end

      shared_examples 'token hash generator' do |in_house|
        before(:each) do
          @expected_in_house = in_house
        end

        subject(:result) { test_lane_execution }

        it 'returns proper hash' do
          expect(result).to eq(expected_hash)
        end
      end

      shared_examples 'global variable setter' do |in_house|
        before(:each) do
          @expected_in_house = in_house
          test_lane_execution
        end

        subject(:global_variable) do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_TOKEN]
        end

        it 'sets global variable' do
          expect(global_variable).to eq(expected_hash)
        end
      end

      shared_examples 'token setter' do |in_house|
        mocked_token = 'mocked token contents'

        before(:each) do
          @expected_in_house = in_house

          allow(Spaceship::ConnectAPI::Token).to receive(:create).and_return(mocked_token)
          allow(Spaceship::ConnectAPI).to receive(:token=)

          test_lane_execution
        end

        it 'calls token create' do
          expect(Spaceship::ConnectAPI::Token).to have_received(:create).with(expected_hash)
        end

        it 'sets spaceship token' do
          expect(Spaceship::ConnectAPI).to have_received(:token=).with(mocked_token)
        end
      end

      shared_examples 'no token setter' do
        before(:each) do
          allow(Spaceship::ConnectAPI).to receive(:token=)

          test_lane_execution
        end

        it 'lefts spaceship token empty' do
          expect(Spaceship::ConnectAPI).to_not(have_received(:token=))
        end
      end

      context 'without any parameter' do
        before(:each) do
          @test_command = 'app_store_connect_api_token'
        end

        it 'raises error' do
          expect do
            test_lane_execution
            Fastlane::FastFile.new.parse(lane).runner.execute(:test)
          end.to raise_error(':token_text or :token_filepath is required')
        end
      end

      context 'with default in_house and set_spaceship_token' do
        in_house_default = false

        context 'with valid token_text' do
          before(:each) do
            @test_command = "app_store_connect_api_token token_text: '#{test_token_jwt_text}'"
          end

          it_behaves_like 'token hash generator', in_house_default
          it_behaves_like 'global variable setter', in_house_default
          it_behaves_like 'token setter', in_house_default
        end

        context 'with valid token_filepath' do
          before(:each) do
            File.write(test_token_jwt_filepath, test_token_jwt_text)
            @test_command = "app_store_connect_api_token token_filepath: '#{test_token_jwt_filepath}'"
          end

          after(:each) do
            File.unlink(test_token_jwt_filepath)
          end

          it_behaves_like 'token hash generator', in_house_default
          it_behaves_like 'global variable setter', in_house_default
          it_behaves_like 'token setter', in_house_default
        end
      end

      context 'with modified in_house and set_spaceship_token' do
        in_house_changed = true

        context 'with valid token_text' do
          before(:each) do
            @test_command = "app_store_connect_api_token token_text: '#{test_token_jwt_text}', in_house: true, set_spaceship_token: false"
          end

          it_behaves_like 'token hash generator', in_house_changed
          it_behaves_like 'global variable setter', in_house_changed
          it_behaves_like 'no token setter'
        end

        context 'with valid token_filepath' do
          before(:each) do
            File.write(test_token_jwt_filepath, test_token_jwt_text)
            @test_command = "app_store_connect_api_token token_filepath: '#{test_token_jwt_filepath}', in_house: true, set_spaceship_token: false"
          end

          after(:each) do
            File.unlink(test_token_jwt_filepath)
          end

          it_behaves_like 'token hash generator', in_house_changed
          it_behaves_like 'global variable setter', in_house_changed
          it_behaves_like 'no token setter'
        end
      end
    end
  end
end
