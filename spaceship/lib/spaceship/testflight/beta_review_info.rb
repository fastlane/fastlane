module Testflight
  class BetaReviewInfo < Base
    attr_accessor :contact_first_name, :contact_last_name, :contact_phone, :contact_email

    attr_mapping({
      'contactFirstName' => :contact_first_name,
      'contactLastName' => :contact_last_name,
      'contactPhone' => :contact_phone,
      'contactEmail' => :contact_email,
    })
  end
end