require 'spec_helper'

describe Spaceship::TestFlight::AppTestInfo do
  let(:app_test_info) do
    Spaceship::TestFlight::AppTestInfo.new({
                                            'primaryLocale' => 'en-US',
                                            'details' => [{
                                              'locale' => 'en-US',
                                              'feedbackEmail' => 'feedback@email.com',
                                              'description' => 'Beta app description',
                                              'whatsNew' => 'What is new'
                                            }],
                                            'betaReviewInfo' => {
                                              'contactFirstName' => 'First',
                                              'contactLastName' => 'Last',
                                              'contactPhone' => '1234567890',
                                              'contactEmail' => 'contact@email.com',
                                              'demoAccountName' => 'User Name',
                                              'demoAccountPassword' => 'Password',
                                              'demoAccountRequired' => false,
                                              'notes' => 'notes!!'
                                            }
                                          })
  end

  let(:test_info) do
    Spaceship::TestFlight::TestInfo.new([
                                          {
                                            'locale' => 'en-US',
                                            'description' => 'en-US description',
                                            'feedbackEmail' => 'enUS@email.com',
                                            'whatsNew' => 'US News'
                                          },
                                          {
                                            'locale' => 'de-DE',
                                            'description' => 'de-DE description',
                                            'feedbackEmail' => 'deDE@email.com',
                                            'whatsNew' => 'German News'
                                          },
                                          {
                                            'locale' => 'de-AT',
                                            'description' => 'de-AT description',
                                            'feedbackEmail' => 'deAT@email.com',
                                            'whatsNew' => 'Austrian News'
                                          }
                                        ])
  end

  let(:beta_review_info) do
    Spaceship::TestFlight::BetaReviewInfo.new({
                                                 'contactFirstName' => 'Test_First',
                                                 'contactLastName' => 'Test_Last',
                                                 'contactPhone' => '2345678901',
                                                 'contactEmail' => 'test_contact@email.com',
                                                 'demoAccountName' => 'Test User Name',
                                                 'demoAccountPassword' => 'Test_Password',
                                                 'demoAccountRequired' => true,
                                                 'notes' => 'test_notes!!'
                                             })
  end

  let(:mock_client) { double('MockClient') }

  before do
    # Use a simple client for all data models
    Spaceship::TestFlight::Base.client = mock_client
  end

  it 'gets the TestInfo' do
    expect(app_test_info.test_info).to be_instance_of(Spaceship::TestFlight::TestInfo)
    expect(app_test_info.test_info.feedback_email).to eq("feedback@email.com")
    expect(app_test_info.test_info.description).to eq("Beta app description")
    expect(app_test_info.test_info.whats_new).to eq('What is new')
  end

  it 'sets the TestInfo' do
    app_test_info.test_info = test_info
    expect(app_test_info.raw_data['details']).to eq(test_info.raw_data)
  end

  it 'gets beta review info' do
    expect(app_test_info.beta_review_info).to be_instance_of(Spaceship::TestFlight::BetaReviewInfo)
    expect(app_test_info.beta_review_info.contact_first_name).to eq("First")
    expect(app_test_info.beta_review_info.contact_last_name).to eq("Last")
    expect(app_test_info.beta_review_info.contact_phone).to eq("1234567890")
    expect(app_test_info.beta_review_info.contact_email).to eq("contact@email.com")
    expect(app_test_info.beta_review_info.demo_account_name).to eq("User Name")
    expect(app_test_info.beta_review_info.demo_account_password).to eq("Password")
    expect(app_test_info.beta_review_info.demo_account_required).to eq(false)
    expect(app_test_info.beta_review_info.notes).to eq("notes!!")
  end

  it 'sets beta review info' do
    app_test_info.beta_review_info = beta_review_info
    expect(app_test_info.raw_data['betaReviewInfo']).to eq(beta_review_info.raw_data)
  end

  context 'client interactions' do
    it 'find app test info on the server' do
      mock_client_response(:get_app_test_info, with: hash_including(app_id: 'app-id')) do
        app_test_info.raw_data
      end

      found_app_test_info = Spaceship::TestFlight::AppTestInfo.find(app_id: 'app-id')
      expect(found_app_test_info).to be_instance_of(Spaceship::TestFlight::AppTestInfo)

      # use to_h.to_s to compare raw_data, since they are different instances
      expect(found_app_test_info.raw_data.to_h.to_s).to eq(app_test_info.raw_data.to_h.to_s)
    end

    RSpec::Matchers.define(:same_app_test_info) do |other_app_test_info|
      match do |args|
        args[:app_test_info].raw_data.to_h.to_s == other_app_test_info.raw_data.to_h.to_s
      end
    end

    it 'updates app test info on the server' do
      expect(app_test_info.client).to receive(:put_app_test_info).with(same_app_test_info(app_test_info))
      app_test_info.save_for_app!(app_id: 'app-id')
    end
  end
end
