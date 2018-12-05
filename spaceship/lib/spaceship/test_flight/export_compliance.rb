require_relative 'base'

module Spaceship::TestFlight
  class ExportCompliance < Base
    attr_accessor :uses_encryption, :encryption_updated

    attr_mapping({
      'usesEncryption' => :uses_encryption,
      'encryptionUpdated' => :encryption_updated
    })
  end
end
