require 'spec_helper'

describe Spaceship::TestFlight::TestInfo do
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
      },
    ])
  end

  it 'gets the value from the first locale' do
    expect(test_info.feedback_email).to eq('enUS@email.com')
    expect(test_info.description).to eq('en-US description')
    expect(test_info.whats_new).to eq('US News')
  end

  it 'sets values to all locales' do
    test_info.whats_new = 'News!'
    expect(test_info.raw_data.all?{|locale| locale['whatsNew'] == 'News!'}).to eq(true)
  end
end
