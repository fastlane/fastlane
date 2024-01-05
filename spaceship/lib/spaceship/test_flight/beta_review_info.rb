require_relative 'base'

module Spaceship::TestFlight
  class BetaReviewInfo < Base
    attr_accessor :contact_first_name, :contact_last_name, :contact_phone, :contact_email
    attr_accessor :demo_account_name, :demo_account_password, :demo_account_required, :notes

    attr_mapping({
      'contactFirstName' => :contact_first_name,
      'contactLastName' => :contact_last_name,
      'contactPhone' => :contact_phone,
      'contactEmail' => :contact_email,
      'demoAccountName' => :demo_account_name,
      'demoAccountPassword' => :demo_account_password,
      'demoAccountRequired' => :demo_account_required,
      'notes' => :notes
    })
  end
end
