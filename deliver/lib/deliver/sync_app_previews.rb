require "fastlane_core"
require "fastlane_core/video_utils"
require "digest/md5"

require_relative 'module'

module Deliver
  class SyncAppPreviews
    UploadPreviewJob = Struct.new(:localization, :preview_set, :video_path, :frame_time_code)

    def initialize(app:, platform:, app_previews_path:, preview_frame_time_code: nil, overwrite_preview_videos: false)
      @app = app
      @platform = platform
      @app_previews_path = app_previews_path
      @frame_time_code = preview_frame_time_code
      @overwrite = overwrite_preview_videos
    end

    def sync_from_path
      UI.important("Uploading App Preview videos...")
      validate_path!

      localizations = editable_version.get_app_store_version_localizations
      locale_by_code = localizations.each_with_object({}) { |l, h| h[l.locale] = l }

      video_paths_per_locale = discover_videos(@app_previews_path)
      if video_paths_per_locale.empty?
        UI.message("No preview videos found under '#{@app_previews_path}'.")
        return
      end

      jobs = []
      video_paths_per_locale.each do |locale, paths|
        process_locale_videos(locale: locale, paths: paths, locale_by_code: locale_by_code, jobs: jobs)
      end

      if jobs.empty?
        UI.message("No new preview videos to upload.")
        return
      end

      UI.message("Queueing #{jobs.size} preview video upload job(s) across #{video_paths_per_locale.keys.size} locale(s)...")

      upload_errors = []
      worker = FastlaneCore::QueueWorker.new do |job|
        begin
          UI.message("Uploading preview video '#{File.basename(job.video_path)}' for locale #{job.localization.locale} (set #{job.preview_set.preview_type})...")
          job.preview_set.upload_preview(path: job.video_path, frame_time_code: job.frame_time_code)
          UI.message("Uploaded preview video '#{File.basename(job.video_path)}' for locale #{job.localization.locale} (set #{job.preview_set.preview_type}).")
        rescue => e
          UI.error("Failed to upload '#{job.video_path}': #{e.class} - #{e.message}")
          upload_errors << e
        end
      end

      jobs.each { |j| worker.enqueue(j) }
      worker.start
      UI.message("All upload jobs finished. Sorting previews by filename...")

      # sort previews in each set by file name
      localizations.each do |loc|
        loc.get_app_preview_sets(includes: "appPreviews").each do |set|
          next unless set.app_previews && set.app_previews.length > 1
          ordered_ids = set.app_previews.sort_by { |preview| preview.file_name.to_s }.map(&:id)
          set.reorder_previews(app_preview_ids: ordered_ids)
        end
      end

      unless upload_errors.empty?
        UI.user_error!("#{upload_errors.size} App Preview upload error(s) occurred. First error: #{upload_errors.first.class} - #{upload_errors.first.message}")
      end

      UI.success("Successfully uploaded and sorted App Preview videos.")
    end

    private

    # process videos for a single locale: infer the types, enforce limits, create/reuse sets, enqueue upload jobs
    def process_locale_videos(locale:, paths:, locale_by_code:, jobs:)
      localization = locale_by_code[locale]
      unless localization
        UI.important("Locale '#{locale}' does not exist on App Store Connect for this version. Skipping its videos.")
        return
      end

      sets_by_preview_type = localization
                             .get_app_preview_sets(includes: "appPreviews")
                             .each_with_object({}) { |set, h| h[set.preview_type] = set }

      if @overwrite
        delete_existing_previews(localization, sets_by_preview_type.values)
        # re-fetch sets after deletes
        sets_by_preview_type = localization
                               .get_app_preview_sets(includes: "appPreviews")
                               .each_with_object({}) { |set, h| h[set.preview_type] = set }
      end

      # group videos by preview type inferred from filename to enforce a max of 3 per locale AND type
      videos_by_preview_type = Hash.new { |h, k| h[k] = [] }
      paths.each do |video_path|
        preview_type = Spaceship::ConnectAPI::AppPreviewSet.preview_type_from_filename(File.basename(video_path))
        unless preview_type
          UI.important("[#{locale}] Could not infer preview type for '#{File.basename(video_path)}'. Skipping.")
          next
        end
        videos_by_preview_type[preview_type] << video_path
      end

      videos_by_preview_type.each do |preview_type, video_paths|
        video_paths.sort!
        if video_paths.size > 3
          UI.important("[#{locale}] Found #{video_paths.size} '#{preview_type}' videos. Limiting to first 3 by filename.")
          video_paths = video_paths.first(3)
        end

        preview_set = sets_by_preview_type[preview_type] || begin
          UI.message("[#{locale}] Creating App Preview Set for type #{preview_type}...")
          created = localization.create_app_preview_set(attributes: { previewType: preview_type })
          sets_by_preview_type[preview_type] = created
        end

        video_paths.each do |video_path|
          already_exist = (preview_set.app_previews || []).any? { |preview| preview.source_file_checksum == Digest::MD5.hexdigest(File.binread(video_path)) }
          if already_exist
            UI.message("[#{locale}] Preview '#{File.basename(video_path)}' already uploaded (matching checksum). Skipping upload.")
            next
          end

          jobs << UploadPreviewJob.new(localization, preview_set, video_path, @frame_time_code)
        end
      end
    end

    def validate_path!
      UI.user_error!("app_previews_path is required") if @app_previews_path.to_s.empty?
      UI.user_error!("app_previews_path '#{@app_previews_path}' does not exist") unless Dir.exist?(@app_previews_path)
    end

    def editable_version
      @app.get_edit_app_store_version(platform: @platform)
    end

    def discover_videos(root)
      extensions = %w[mp4 mov m4v]
      locales = Dir.children(root).select { |subdir| File.directory?(File.join(root, subdir)) }
      result = {}
      locales.each do |locale|
        dir = File.join(root, locale)
        video_paths = Dir.children(dir)
                         .select { |filename| extensions.include?(File.extname(filename).delete(".").downcase) }
                         .map { |filename| File.join(dir, filename) }
                         .sort
        valid_video_paths = []
        video_paths.each do |path|
          # require filename to contain a known preview type token
          inferred_from_name = Spaceship::ConnectAPI::AppPreviewSet.preview_type_from_filename(File.basename(path))
          unless inferred_from_name
            UI.important("[#{locale}] '#{File.basename(path)}' does not contain any known preview device type. Skipping.")
            next
          end

          # enforce size constraint (under 500MB)
          size_mb = File.size(path) / (1024.0 * 1024.0)
          if size_mb > 500
            UI.important("[#{locale}] '#{File.basename(path)}' is #{size_mb.round(1)}MB (> 500MB). Skipping.")
            next
          end

          # enforce duration constraints [15s..30s]. warn if duration can't be determined
          duration = FastlaneCore::VideoUtils.read_video_duration_seconds(path)
          if duration
            if duration < 15.0 || duration > 30.0
              UI.important("[#{locale}] '#{File.basename(path)}' duration is #{duration.round(2)}s (allowed: 15–30s). Skipping.")
              next
            end
          else
            UI.important("[#{locale}] Could not determine duration for '#{File.basename(path)}'. Proceeding anyway.")
          end

          # validate resolution against accepted canonical sizes; warn if resolution can't be determined
          res = FastlaneCore::VideoUtils.read_video_resolution(path)
          if res
            unless Spaceship::ConnectAPI::AppPreviewSet.validate_video_resolution(res[0], res[1])
              UI.important("[#{locale}] '#{File.basename(path)}' has invalid resolution #{res.join('x')}. Skipping.")
              next
            end
          else
            UI.important("[#{locale}] Could not determine resolution for '#{File.basename(path)}'. Proceeding anyway.")
          end
          valid_video_paths << path
        end
        result[locale] = valid_video_paths unless valid_video_paths.empty?
      end
      result
    end

    def delete_existing_previews(localization, sets)
      sets.each do |set|
        next unless set.app_previews && set.app_previews.any?
        UI.message("Deleting #{set.app_previews.size} existing previews from set #{set.preview_type} for locale #{localization.locale} due to overwrite...")
        set.app_previews.each do |preview|
          begin
            preview.delete!
          rescue => e
            UI.error("Failed to delete preview '#{preview.file_name}': #{e.class} - #{e.message}")
          end
        end
      end
    end
  end
end
