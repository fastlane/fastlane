require "spec_helper"
require "deliver/sync_app_previews"
require "fastlane_core/video_utils"
require "base64"
require "zlib"
require "fileutils"

describe Deliver::SyncAppPreviews do
  let(:app) { double("Spaceship::ConnectAPI::App") }
  let(:platform) { Spaceship::ConnectAPI::Platform::IOS }
  let(:tmp_root) { Dir.mktmpdir("app-previews-") }

  after do
    FileUtils.remove_dir(tmp_root) if File.directory?(tmp_root)
  end

  # helper to make locale dirs and write files
  def write_preview_file(locale:, name:, bytes:)
    dir = File.join(tmp_root, locale)
    FileUtils.mkdir_p(dir)
    path = File.join(dir, name)
    File.binwrite(path, bytes)
    path
  end

  # helper to make locale dirs and copy existing file
  def copy_preview_file(locale:, source:, dest:)
    dir = File.join(tmp_root, locale)
    FileUtils.mkdir_p(dir)
    path = File.join(dir, dest)
    FileUtils.cp(File.expand_path(File.join(__dir__, "resources", "app_previews", source)), path)
    path
  end

  # shared mocks for Spaceship API to interact with
  def stub_spaceship_api(locales:, existing_sets: {}, uploaded_files_by_locale_and_type: nil)
    version = double("AppStoreVersion")
    allow(app).to receive(:get_edit_app_store_version).with(platform: platform).and_return(version)

    localizations = locales.map do |code|
      double("Localization-#{code}", locale: code)
    end
    allow(version).to receive(:get_app_store_version_localizations).and_return(localizations)

    # for each localization, mock preview sets retrieval/creation and reordering
    localizations.each do |loc|
      allow(loc).to receive(:get_app_preview_sets).with(includes: "appPreviews") { existing_sets[loc.locale] || [] }

      allow(loc).to receive(:create_app_preview_set) do |attributes:|
        type = attributes[:previewType]
        # use a struct-like mock to track uploads per set
        set = double("Set-#{loc.locale}-#{type}", preview_type: type, app_previews: [], locale: loc.locale)
        allow(set).to receive(:upload_preview) do |path:, frame_time_code:|
          # simulate that an AppPreview object is returned
          uploaded_files_by_locale_and_type[loc.locale][type] << File.basename(path) if uploaded_files_by_locale_and_type
          double("AppPreview", file_name: File.basename(path))
        end
        allow(set).to receive(:reorder_previews) do |app_preview_ids:|
          set # return updated preview set structure
        end
        # update existing_sets for subsequent calls
        existing_sets[loc.locale] ||= []
        existing_sets[loc.locale] << set
        set
      end
    end

    existing_sets
  end

  it "groups by inferred type, limits to 3 per type per locale, uploads and sorts" do
    targets = {
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_40 => "1080x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_47 => "750x1334",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_55 => "1080x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_58 => "1080x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_61 => "886x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_65 => "886x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67 => "886x1920",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_97 => "900x1200",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_105 => "1200x1600",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_PRO_129 => "1200x1600",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_PRO_3GEN_11 => "1200x1600",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_PRO_3GEN_129 => "1200x1600",
    }
    # copy video files for each locale and device (up to 4 files)
    locales = %w[en se]
    locales.each do |locale|
      targets.each do |device, res|
        (1..4).each do |i|
          copy_preview_file(locale: locale, source: "#{res}.mp4", dest: "#{device}_#{res}_#{i}.mp4")
        end
      end
    end

    # mock Spaceship APIs
    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    sets_map = stub_spaceship_api(locales: locales, existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    # extent the doubles to capture preview_set behavior
    locales.each do |locale|
      allow(sets_map).to receive(:[]).and_call_original
    end

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: "00:00:00:01",
      overwrite_preview_videos: false
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error

    # Expectations:
    # - max 3 files should be uploaded per locale and per locale
    # - sorting happens by filename
    targets.keys.each do |target|
      locales.each do |loc|
        # if any uploads happened for this type, it should be exactly 3 per locale
        next unless uploaded_files_by_locale_and_type[loc][target].any?
        expect(uploaded_files_by_locale_and_type[loc][target].size).to eq(3)
        # uploaded files are the first three lexicographically
        sorted = uploaded_files_by_locale_and_type[loc][target].sort
        expect(sorted).to eq(sorted.take(3))
        expect(sorted.all? { |file_name| file_name.end_with?('_1.mp4', '_2.mp4', '_3.mp4') }).to be(true)
      end
    end
  end

  it "uploads by inferring type from filename when resolution parsing fails" do
    # make fixtures where bytes are not valid videos, to force resolution parser to return nil
    locale = "en"
    videos = {
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_55 => "unknown-video-format",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_65 => "unknown-video-format",
      Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPAD_105  => "unknown-video-format"
    }
    fixtures = []
    videos.each do |type, content|
      (1..4).each do |i|
        fixtures << { name: "#{type}_#{i}.mp4", bytes: content }
      end
    end

    fixtures.each do |fixture|
      write_preview_file(locale: locale, name: fixture[:name], bytes: fixture[:bytes])
    end

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error

    videos.keys.each do |device| # expect the type was inferred from filename and max 3 files
      expect(uploaded_files_by_locale_and_type[locale][device].size).to eq(3)
    end
  end

  it "does nothing if resolution and filename inference both fail" do
    # files w/o recognizable video meta and invalid name
    locale = "en"
    bad_names = %w[foo.mp4 bar.mov baz.m4v]
    bad_names.each do |name|
      write_preview_file(locale: locale, name: name, bytes: "invalid-video-file")
    end

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error
    # no uploads should happen
    expect(uploaded_files_by_locale_and_type[locale].values.flatten).to be_empty
  end

  it "skips when a video file is over 500MB" do
    # make a "valid" video file and stub File.size to be huge
    locale = "en"
    file_name = "#{Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67}_1.mp4"
    write_preview_file(locale: locale, name: file_name, bytes: "some-video")

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # capture UI.important messages
    warnings = []
    allow(UI).to receive(:important) { |msg| warnings << msg }
    # mock File.size to return > 500MB for our file only
    allow(File).to receive(:size).and_call_original
    allow(File).to receive(:size).with(File.join(tmp_root, locale, file_name)).and_return(501 * 1024 * 1024)

    # run
    expect { sync.sync_from_path }.not_to raise_error

    # check the warning message and no uploads should happen
    expect(warnings.any? { |w| w.include?(file_name) && w.include?("> 500MB") }).to be(true)
    expect(uploaded_files_by_locale_and_type[locale].values.flatten).to be_empty
  end

  it "skips videos shorter than 15s and longer than 30s (logs and no uploads)" do
    locale = "en"
    device = Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67
    short_video_path = copy_preview_file(locale: locale, source: "886x1920_short.mp4", dest: "#{device}_short.mp4")
    long_video_path = copy_preview_file(locale: locale, source: "886x1920_long.mp4", dest: "#{device}_long.mp4")

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    warnings = []
    allow(UI).to receive(:important) { |msg| warnings << msg }

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    expect { sync.sync_from_path }.not_to raise_error

    expect(uploaded_files_by_locale_and_type[locale][device]).to be_empty
    expect(warnings.any? { |w| w.include?(File.basename(short_video_path)) && w.include?("duration is 1.0s") }).to be(true)
    expect(warnings.any? { |w| w.include?(File.basename(long_video_path)) && w.include?("duration is 31.0s") }).to be(true)
  end

  it "skips upload when a preview with matching checksum already exists" do
    locale = "en"
    device = Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67
    content = "some-video"
    write_preview_file(locale: locale, name: "#{device}_1.mp4", bytes: content)
    checksum = Digest::MD5.hexdigest(content)

    existing_sets = {
      locale => [
        double("ExistingSet", preview_type: device, app_previews: [double("ExistingPreview", source_file_checksum: checksum, file_name: "#{device}_1.mp4")])
      ]
    }

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: existing_sets, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error

    # upload should be skipped
    expect(uploaded_files_by_locale_and_type[locale][device]).to be_empty
  end

  it "deletes all existing previews when overwrite is enabled before uploading" do
    locale = "en"
    device = Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67
    write_preview_file(locale: locale, name: "#{device}_1.mp4", bytes: "some-video")

    existing_preview1 = double("Prev1", file_name: "existing-video-1")
    existing_preview2 = double("Prev2", file_name: "existing-video-2")
    allow(existing_preview1).to receive(:source_file_checksum).and_return("existing-checksum-1")
    allow(existing_preview2).to receive(:source_file_checksum).and_return("existing-checksum-2")
    allow(existing_preview1).to receive(:delete!)
    allow(existing_preview2).to receive(:delete!)
    allow(existing_preview1).to receive(:id).and_return("id1")
    allow(existing_preview2).to receive(:id).and_return("id2")

    existing_set = double("ExistingSet", preview_type: device, app_previews: [existing_preview1, existing_preview2])
    # mock upload/reorder on existing set since overwrite will reuse the set
    allow(existing_set).to receive(:upload_preview) do |path:, frame_time_code:|
      double("AppPreview", file_name: File.basename(path))
    end
    allow(existing_set).to receive(:reorder_previews) { existing_set }
    existing_sets = { locale => [existing_set] }

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: existing_sets, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: true
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error

    # check that existing previews were deleted
    expect(existing_preview1).to have_received(:delete!).at_least(:once)
    expect(existing_preview2).to have_received(:delete!).at_least(:once)
  end

  it "ignores unsupported video file extensions" do
    locale = "en"
    device = Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67
    # supported video
    write_preview_file(locale: locale, name: "#{device}_1.mp4", bytes: "some-video")
    # unsupported videos
    write_preview_file(locale: locale, name: "movie.avi", bytes: "some-unsupported-video")
    write_preview_file(locale: locale, name: "clip.mkv", bytes: "some-unsupported-video")

    uploaded_files_by_locale_and_type = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    stub_spaceship_api(locales: [locale], existing_sets: {}, uploaded_files_by_locale_and_type: uploaded_files_by_locale_and_type)

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # run
    expect { sync.sync_from_path }.not_to raise_error

    # only the supported .mp4 is uploaded
    expect(uploaded_files_by_locale_and_type[locale][device].size).to eq(1)
  end

  it "collects upload errors and raises at end" do
    locale = "en"
    device = Spaceship::ConnectAPI::AppPreviewSet::PreviewType::IPHONE_67
    error_message = "mocked error message"
    write_preview_file(locale: locale, name: "#{device}_1.mp4", bytes: "some-video")

    # redo the mocks on Spaceship API to forcibly raise err on upload
    version = double("AppStoreVersion")
    allow(app).to receive(:get_edit_app_store_version).with(platform: platform).and_return(version)
    loc = double("Localization-#{locale}", locale: locale)
    allow(version).to receive(:get_app_store_version_localizations).and_return([loc])
    set = double("Preview-Set-#{locale}-#{device}", preview_type: device, app_previews: [])
    allow(loc).to receive(:get_app_preview_sets).with(includes: "appPreviews").and_return([])
    allow(loc).to receive(:create_app_preview_set).with(attributes: { previewType: device }).and_return(set)
    allow(set).to receive(:upload_preview).and_raise(StandardError.new(error_message))
    allow(set).to receive(:reorder_previews) { set }

    sync = Deliver::SyncAppPreviews.new(
      app: app,
      platform: platform,
      app_previews_path: tmp_root,
      preview_frame_time_code: nil,
      overwrite_preview_videos: false
    )

    # run and expect error
    expect { sync.sync_from_path }.to raise_error(FastlaneCore::Interface::FastlaneError, /1 App Preview upload error.+ #{error_message}/)
  end
end
