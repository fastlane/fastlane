require 'spaceship'
require_relative 'module'

module Deliver
  class UploadCreativeAssets
    ASSET_CATEGORY = 'CREATIVE_ASSETS'.freeze
    FEATURE_ID = 'APP_STORE_VERSIONS'.freeze
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

    def check(options)
      # The metadata upload can create localizations that do not exist yet.
      placement_plans(options, allow_missing_localizations: true)
    end

    def upload(options)
      plans = placement_plans(options, allow_missing_localizations: false)
      return if plans.empty?

      library = Spaceship::ConnectAPI::AppAssetLibrary.get(app_id: Deliver.cache[:app].id)
      UI.user_error!('Apple returned no asset library for this app') unless library
      uploaded_images_by_path = {}
      plans.each { |plan| prepare_image(plan, library, uploaded_images_by_path) }
      plans.each { |plan| replace_placement(plan) }
      UI.success('Successfully uploaded and placed creative assets')
    end

    private

    def placement_plans(options, allow_missing_localizations:)
      entries = options[:creative_assets]
      return [] if entries.nil? || entries.empty?
      self.class.validate(entries)

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
      entries.filter_map do |entry|
        entry = entry.transform_keys(&:to_sym)
        specs = compatible_specs(reference, entry)
        localization = localizations.find { |item| item.locale == entry[:locale] }
        next if allow_missing_localizations && !localization
        UI.user_error!("No existing version localization for '#{entry[:locale]}'") unless localization
        placements = Spaceship::ConnectAPI::AppAssetLibraryPlacement.all(app_store_version_localization_id: localization.id)
        existing = placements.select { |item| item.placement_type == entry[:placement_type] && item.placement_group == entry[:placement_group] }
        if !existing.empty? && !options[:overwrite_creative_assets]
          UI.user_error!("Creative asset already placed for #{entry[:locale]} / #{entry[:placement_type]} / #{entry[:placement_group]}; set overwrite_creative_assets: true to replace it")
        end
        { entry:, localization:, specs:, existing: }
      end
    end

    def compatible_specs(reference, entry)
      feature = Array(reference.features).find { |item| item['featureId'] == FEATURE_ID }
      policy = Array(feature&.dig('placementPolicies')).find { |item| item['placementType'] == entry[:placement_type] }
      allowed = Array(policy&.dig('groupLimits')).any? do |group|
        Array(group['groupIds']).include?(entry[:placement_group]) && group['maxCount'].to_i > 0
      end
      type = Array(reference.placement_types).find { |item| item['placementTypeId'] == entry[:placement_type] }
      mapping = Array(type&.dig('specMappings')).find { |item| item['placementGroupId'] == entry[:placement_group] }
      specs = Array(mapping&.dig('specs'))
      unless allowed && Array(type&.dig('acceptsAssetCategories')).include?(ASSET_CATEGORY) && !specs.empty?
        UI.user_error!("Creative asset target is not supported by Apple's current reference data: #{entry[:placement_type]} / #{entry[:placement_group]}")
      end
      specs
    end

    def prepare_image(plan, library, uploaded_images_by_path)
      entry = plan[:entry]
      path = File.expand_path(entry[:path])
      # Reuse a universal image for both placements and across localizations.
      image = uploaded_images_by_path[path] ||= Spaceship::ConnectAPI::AppAssetLibraryImage.create(
        app_asset_library_id: library.id, path: path, category: ASSET_CATEGORY
      )
      unless plan[:specs].include?(image.spec_id)
        UI.user_error!("Uploaded image '#{image.id}' is not compatible with #{entry[:placement_type]} / #{entry[:placement_group]}; all existing placements were preserved")
      end

      plan[:image] = image
    end

    def replace_placement(plan)
      entry = plan[:entry]
      completed_deletions = []
      operation = 'delete'
      deletion_id = nil
      # Apple placements are immutable; all images are ready before this phase.
      plan[:existing].each do |placement|
        deletion_id = placement.id
        placement.delete!
        completed_deletions << placement.id
      end
      operation = 'create'
      deletion_id = nil
      Spaceship::ConnectAPI::AppAssetLibraryPlacement.create(
        app_store_version_localization_id: plan[:localization].id,
        image_id: plan[:image].id,
        placement_type: entry[:placement_type],
        placement_group: entry[:placement_group]
      )
    rescue StandardError => error
      # A transport error can occur after Apple applied the mutation. Read back
      # once for diagnostics, but do not infer success or repeat any mutation.
      observed = placement_readback(plan)
      failed_deletion = deletion_id ? "Failed deletion ID: #{deletion_id}. " : ''
      UI.user_error!("Could not #{operation} creative asset placement for #{entry.values_at(:locale, :placement_type, :placement_group).join(' / ')}. " \
                     "Old placement IDs: #{plan[:existing].map(&:id).join(', ')}. New image ID: #{plan[:image].id}. " \
                     "#{failed_deletion}Completed deletions: #{completed_deletions.join(', ')}. Original error: #{error.message}. #{observed} " \
                     "The outcome remains uncertain; readback may be stale. No further placement mutations, retries, or rollback were attempted. " \
                     "Check current placements and exact image IDs in App Store Connect before retrying.")
    end

    def placement_readback(plan)
      entry = plan[:entry]
      placements = Spaceship::ConnectAPI::AppAssetLibraryPlacement.all(
        app_store_version_localization_id: plan[:localization].id, includes: 'image'
      )
      matching = placements.select do |placement|
        placement.placement_type == entry[:placement_type] && placement.placement_group == entry[:placement_group]
      end
      observed = matching.map do |placement|
        image_id = placement.image && placement.image.id
        "#{placement.id} (image #{image_id || 'unknown'})"
      end
      "Readback placements: #{observed.empty? ? 'none observed' : observed.join(', ')}."
    rescue StandardError => error
      "Readback failed: #{error.message}."
    end
  end
end
