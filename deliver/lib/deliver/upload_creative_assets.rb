require 'spaceship'
require_relative 'module'

module Deliver
  class UploadCreativeAssets
    PLACEMENT_TYPES = %w[PRODUCT_PAGE_HEADER_ASSET APP_STORE_SEARCH_RESULTS_ASSET].freeze
    REQUIRED_KEYS = %i[locale path placement_type placement_group].freeze
    EDITABLE_VERSION_STATES = %w[PREPARE_FOR_SUBMISSION DEVELOPER_REJECTED REJECTED METADATA_REJECTED INVALID_BINARY].freeze

    def self.validate(entries)
      targets = []
      entries.each do |entry|
        UI.user_error!('Each creative_assets entry must be a Hash') unless entry.kind_of?(Hash)
        entry = entry.transform_keys(&:to_sym)
        UI.user_error!("Unknown creative_assets keys: #{entry.keys - REQUIRED_KEYS}") unless (entry.keys - REQUIRED_KEYS).empty?
        REQUIRED_KEYS.each do |key|
          UI.user_error!("creative_assets requires a nonempty #{key}") unless entry[key].kind_of?(String) && !entry[key].strip.empty?
        end
        UI.user_error!("Unsupported creative asset placement_type: #{entry[:placement_type]}") unless PLACEMENT_TYPES.include?(entry[:placement_type])
        UI.user_error!("Could not find creative asset '#{entry[:path]}'") unless File.file?(entry[:path])
        UI.user_error!('Creative assets currently support PNG or JPEG images') unless %w[.png .jpg .jpeg].include?(File.extname(entry[:path]).downcase)
        target = entry.values_at(:locale, :placement_type, :placement_group)
        UI.user_error!("Duplicate creative asset target: #{target.join(' / ')}") if targets.include?(target)
        targets << target
      end
    end

    def self.validate_options(options)
      entries = options[:creative_assets]
      return if entries.nil? || entries.empty?
      if options[:edit_live] || options[:use_live_version]
        UI.user_error!('Creative asset uploads require an editable version; edit_live and use_live_version are not supported')
      end
    end

    def upload(options)
      entries = options[:creative_assets]
      return if entries.nil? || entries.empty?
      self.class.validate(entries)
      self.class.validate_options(options)

      app = Deliver.cache[:app]
      version = app.get_edit_app_store_version(platform: Spaceship::ConnectAPI::Platform.map(options[:platform]))
      UI.user_error!('Could not find a version to edit for creative assets') unless version
      unless EDITABLE_VERSION_STATES.include?(version.app_version_state)
        UI.user_error!("Creative asset placements cannot be edited in version state #{version.app_version_state.inspect}; return the version to an editable state before uploading")
      end
      localizations = version.get_app_store_version_localizations
      reference = Spaceship::ConnectAPI::AppAssetLibraryRefDatum.all.first
      UI.user_error!('Apple returned no asset library reference data') unless reference

      # Check every target before uploading files or removing existing placements.
      plans = entries.map do |entry|
        entry = entry.transform_keys(&:to_sym)
        localization = localizations.find { |item| item.locale == entry[:locale] }
        UI.user_error!("No existing version localization for '#{entry[:locale]}'") unless localization
        specs = compatible_specs(reference, entry)
        placements = Spaceship::ConnectAPI::AppAssetLibraryPlacement.all(app_store_version_localization_id: localization.id)
        existing = placements.select { |item| item.placement_type == entry[:placement_type] && item.placement_group == entry[:placement_group] }
        if !existing.empty? && !options[:overwrite_creative_assets]
          UI.user_error!("Creative asset already placed for #{entry[:locale]} / #{entry[:placement_type]} / #{entry[:placement_group]}; set overwrite_creative_assets: true to replace it")
        end
        { entry: entry, localization: localization, specs: specs, existing: existing }
      end

      library = Spaceship::ConnectAPI::AppAssetLibrary.get(app_id: app.id)
      UI.user_error!('Apple returned no asset library for this app') unless library
      uploaded = {}
      plans.each { |plan| upload_and_place(plan, library, uploaded) }
      UI.success('Successfully uploaded and placed creative assets')
    end

    private

    def compatible_specs(reference, entry)
      feature = (reference.features || []).find { |item| item['featureId'] == 'APP_STORE_VERSIONS' }
      policy = (feature || {}).fetch('placementPolicies', []).find { |item| item['placementType'] == entry[:placement_type] }
      allowed = (policy || {}).fetch('groupLimits', []).any? do |group|
        group.fetch('groupIds', []).include?(entry[:placement_group]) && group.fetch('maxCount', 0) > 0
      end
      type = (reference.placement_types || []).find { |item| item['placementTypeId'] == entry[:placement_type] }
      mapping = (type || {}).fetch('specMappings', []).find { |item| item['placementGroupId'] == entry[:placement_group] }
      unless allowed && (type || {}).fetch('acceptsAssetCategories', []).include?('CREATIVE_ASSETS') && mapping
        UI.user_error!("Creative asset target is not supported by Apple's current reference data: #{entry[:placement_type]} / #{entry[:placement_group]}")
      end
      mapping.fetch('specs', [])
    end

    def upload_and_place(plan, library, uploaded)
      entry = plan[:entry]
      path = File.expand_path(entry[:path])
      # Reuse a universal image for both placements and across localizations.
      image = uploaded[path] ||= Spaceship::ConnectAPI::AppAssetLibraryImage.create(
        app_asset_library_id: library.id, path: path, category: 'CREATIVE_ASSETS'
      )
      unless plan[:specs].include?(image.spec_id)
        UI.user_error!("Uploaded image '#{image.id}' is not compatible with #{entry[:placement_type]} / #{entry[:placement_group]}; existing placements were preserved for this target")
      end

      # Apple placements are immutable. Keep the old placement until the image is ready.
      plan[:existing].each(&:delete!)
      Spaceship::ConnectAPI::AppAssetLibraryPlacement.create(
        app_store_version_localization_id: plan[:localization].id,
        image_id: image.id,
        placement_type: entry[:placement_type],
        placement_group: entry[:placement_group]
      )
    end
  end
end
