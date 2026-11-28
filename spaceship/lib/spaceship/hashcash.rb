require 'digest'

module Spaceship
  module Hashcash
    # This App Store Connect hashcash spec was generously donated by...
    #
    #                         __  _
    #    __ _  _ __   _ __   / _|(_)  __ _  _   _  _ __  ___  ___
    #   / _` || '_ \ | '_ \ | |_ | | / _` || | | || '__|/ _ \/ __|
    #  | (_| || |_) || |_) ||  _|| || (_| || |_| || |  |  __/\__ \
    #   \__,_|| .__/ | .__/ |_|  |_| \__, | \__,_||_|   \___||___/
    #         |_|    |_|             |___/
    #
    #
    # <summary>
    #             1:11:20230223170600:4d74fb15eb23f465f1f6fcbf534e5877::6373
    # X-APPLE-HC: 1:11:20230223170600:4d74fb15eb23f465f1f6fcbf534e5877::6373
    #             ^  ^      ^                       ^                     ^
    #             |  |      |                       |                     +-- Counter
    #             |  |      |                       +-- Resource
    #             |  |      +-- Date YYMMDD[hhmm[ss]]
    #             |  +-- Bits (number of leading zeros)
    #             +-- Version
    #
    # We can't use an off-the-shelf Hashcash because Apple's implementation is not quite the same as the spec/convention.
    #  1. The spec calls for a nonce called "Rand" to be inserted between the Ext and Counter. They don't do that at all.
    #  2. The Counter conventionally encoded as base-64 but Apple just uses the decimal number's string representation.
    #
    # Iterate from Counter=0 to Counter=N finding an N that makes the SHA1(X-APPLE-HC) lead with Bits leading zero bits
    #
    #
    # We get the "Resource" from the X-Apple-HC-Challenge header and Bits from X-Apple-HC-Bits
    #
    # </summary>
    def self.make(bits:, challenge:)
      version = 1
      date = Time.now.strftime("%Y%m%d%H%M%S")

      counter = 0
      loop do
        hc = [
          version, bits, date, challenge, ":#{counter}"
        ].join(":")

        if Digest::SHA1.digest(hc).unpack1('B*')[0, bits.to_i].to_i == 0
          return hc
        end
        counter += 1
      end
    end
  end
end
