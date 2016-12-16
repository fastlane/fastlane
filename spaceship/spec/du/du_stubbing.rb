def du_fixture_file_path(filename)
  File.join('spaceship', 'spec', 'du', 'fixtures', filename)
end

def du_read_fixture_file(filename)
  File.read(du_fixture_file_path(filename))
end

# those represent UploadFile structures
def du_uploadimage_correct_screenshot
  mock_jpg = double
  allow(mock_jpg).to receive(:file_name).and_return('ftl_FAKEMD5_screenshot1024.jpg')
  allow(mock_jpg).to receive(:file_size).and_return(1_234_520)
  allow(mock_jpg).to receive(:content_type).and_return('image/jpeg')
  allow(mock_jpg).to receive(:bytes).and_return("the screenshot...")
  mock_jpg
end

def du_uploadimage_correct_jpg
  mock_jpg = double
  allow(mock_jpg).to receive(:file_name).and_return('ftl_FAKEMD5_icon1024.jpg')
  allow(mock_jpg).to receive(:file_size).and_return(520)
  allow(mock_jpg).to receive(:content_type).and_return('image/jpeg')
  allow(mock_jpg).to receive(:bytes).and_return("binary image...")
  mock_jpg
end

def du_uploadtrailer_correct_mov
  mock_jpg = double
  allow(mock_jpg).to receive(:file_name).and_return('ftl_FAKEMD5_trailer-en-US.mov')
  allow(mock_jpg).to receive(:file_size).and_return(123_456)
  allow(mock_jpg).to receive(:content_type).and_return('video/quicktime')
  allow(mock_jpg).to receive(:bytes).and_return("binary video...")
  mock_jpg
end

def du_uploadtrailer_preview_correct_jpg
  mock_jpg = double
  allow(mock_jpg).to receive(:file_name).and_return('ftl_FAKEMD5_trailer-en-US_preview.jpg')
  allow(mock_jpg).to receive(:file_size).and_return(12_345)
  allow(mock_jpg).to receive(:content_type).and_return('image/jpg')
  allow(mock_jpg).to receive(:bytes).and_return("trailer preview...")
  mock_jpg
end

def du_uploadimage_invalid_png
  mock_jpg = double
  allow(mock_jpg).to receive(:file_name).and_return('ftl_FAKEMD5_icon1024.jpg')
  allow(mock_jpg).to receive(:file_size).and_return(520)
  allow(mock_jpg).to receive(:content_type).and_return('image/png')
  allow(mock_jpg).to receive(:bytes).and_return("invalid binary image...")
  mock_jpg
end

def du_read_upload_geojson_response_success
  du_read_fixture_file('upload_geojson_response_success.json')
end

def du_read_upload_geojson_response_failed
  du_read_fixture_file('upload_geojson_response_failed.json')
end

def du_upload_valid_geojson
  Spaceship::UploadFile.from_path(du_fixture_file_path('upload_valid.geojson'))
end

def du_upload_invalid_geojson
  Spaceship::UploadFile.from_path(du_fixture_file_path('upload_invalid.GeoJSON'))
end

def du_read_upload_screenshot_response_success
  du_read_fixture_file('upload_screenshot_response_success.json')
end

def du_read_upload_trailer_preview_response_success
  du_read_fixture_file('upload_trailer_preview_response_success.json')
end

def du_read_upload_trailer_preview_2_response_success
  du_read_fixture_file('upload_trailer_preview_2_response_success.json')
end

def du_upload_large_image_success
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "binary image...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '520', 'Content-Type' => 'image/jpeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'sso token for image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.LargeApplicationIcon', 'X-Original-Filename' => 'ftl_FAKEMD5_icon1024.jpg' }).
    to_return(status: 201, body: du_read_fixture_file('upload_image_success.json'), headers: { 'Content-Type' => 'application/json' })
end

def du_upload_watch_image_failure
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "invalid binary image...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '520', 'Content-Type' => 'image/png', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'sso token for image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.GizmoAppIcon', 'X-Original-Filename' => 'ftl_FAKEMD5_icon1024.jpg' }).
    to_return(status: 400, body: du_read_fixture_file('upload_image_failed.json'), headers: { 'Content-Type' => 'application/json' })
end

def du_upload_geojson_success
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/geo-json").
    with(body: du_upload_valid_geojson.bytes,
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '224', 'Content-Type' => 'application/json', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'sso token for image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Original-Filename' => 'ftl_FAKEMD5_upload_valid.geojson' }).
    to_return(status: 201, body: du_read_upload_geojson_response_success, headers: { 'Content-Type' => 'application/json' })
end

def du_upload_geojson_failure
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/geo-json").
    with(body: du_upload_invalid_geojson.bytes,
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '243', 'Content-Type' => 'application/json', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'sso token for image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Original-Filename' => 'ftl_FAKEMD5_upload_invalid.GeoJSON' }).
    to_return(status: 400, body: du_read_upload_geojson_response_failed, headers: { 'Content-Type' => 'application/json' })
end

def du_upload_screenshot_success
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "the screenshot...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '1234520', 'Content-Type' => 'image/jpeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'the_sso_token_for_image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.SortedN41ScreenShot', 'X-Original-Filename' => 'ftl_FAKEMD5_screenshot1024.jpg' }).
    to_return(status: 201, body: du_read_upload_screenshot_response_success, headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "the screenshot...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '1234520', 'Content-Type' => 'image/jpeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'User-Agent' => "Spaceship #{Fastlane::VERSION}", 'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567',
                     'X-Apple-Upload-Itctoken' => 'the_sso_token_for_image', 'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.SortedScreenShot', 'X-Original-Filename' => 'ftl_FAKEMD5_screenshot1024.jpg' }).
    to_return(status: 201, body: du_read_upload_screenshot_response_success, headers: { 'Content-Type' => 'application/json' })
end

def du_upload_messages_screenshot_success
  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "the screenshot...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '1234520', 'Content-Type' => 'image/jpeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'the_sso_token_for_image',
                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.SortedN41MessagesScreenShot', 'X-Original-Filename' => 'ftl_FAKEMD5_screenshot1024.jpg' }).
    to_return(status: 201, body: du_read_upload_screenshot_response_success, headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://du-itc.itunes.apple.com/upload/image").
    with(body: "the screenshot...",
           headers: { 'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '1234520', 'Content-Type' => 'image/jpeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
                     'User-Agent' => "Spaceship #{Fastlane::VERSION}", 'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567',
                     'X-Apple-Upload-Itctoken' => 'the_sso_token_for_image', 'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Apple-Upload-Validation-Rulesets' => 'MZPFT.SortedScreenShot', 'X-Original-Filename' => 'ftl_FAKEMD5_screenshot1024.jpg' }).
    to_return(status: 201, body: du_read_upload_screenshot_response_success, headers: { 'Content-Type' => 'application/json' })
end

# def du_upload_video_preview_success
#  stub_request(:post, "https://du-itc.itunes.apple.com/upload/app-screenshot-image").
#      with(body: "trailer preview...",
#           headers: {'Accept' => 'application/json, text/plain, */*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Length' => '12345', 'Content-Type' => 'image/joeg', 'Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088',
#                     'User-Agent' => 'spaceship', 'X-Apple-Jingle-Correlation-Key' => 'iOS App:AdamId=898536088:Version=0.9.13', 'X-Apple-Upload-Appleid' => '898536088', 'X-Apple-Upload-Contentproviderid' => '1234567', 'X-Apple-Upload-Itctoken' => 'the_sso_token_for_image',
#                     'X-Apple-Upload-Referrer' => 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088', 'X-Original-Filename' => 'ftl_FAKEMD5_trailer-en-US_preview.jpg'}).
#      to_return(status: 201, body: du_read_upload_trailer_preview_response_success, headers: {'Content-Type' => 'application/json'})
# end
