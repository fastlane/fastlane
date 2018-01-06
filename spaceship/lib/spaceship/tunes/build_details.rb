require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents the details of a build
    class BuildDetails < TunesBase
      # @return (String) The App identifier of this app, provided by iTunes Connect
      # @example
      #   "1013943394"
      attr_accessor :apple_id

      # @return (String) Link to the dSYM file (not always available)
      #     lol, it's unencrypted http
      attr_accessor :dsym_url

      # @return [Bool]
      attr_accessor :include_symbols

      # @return [Integer]
      attr_accessor :number_of_asset_packs

      # @return [Bool]
      attr_accessor :contains_odr

      # e.g. "13A340"
      attr_accessor :build_sdk

      # @return [String] e.g. "MyApp.ipa"
      attr_accessor :file_name

      attr_mapping(
        'apple_id' => :apple_id,
        'dsymurl' => :dsym_url,
        'includesSymbols' => :include_symbols,
        'numberOfAssetPacks' => :number_of_asset_packs,
        'containsODR' => :contains_odr,
        'buildSdk' => :build_sdk,
        'fileName' => :file_name
      )
    end
  end
end
