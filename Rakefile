require "bundler/gem_tasks"

GEMS = %w(fastlane danger-device_grid)
RAILS = %w(boarding refresher enhancer)

SECONDS_PER_DAY = 60 * 60 * 24

BUILD_NUMBER = '6'

task :yolo do
  require 'dotenv'; Dotenv.load
  require 'spaceship'
  Spaceship::Tunes.login(ENV['APPLE_ID'])
  app = Spaceship::Tunes::Application.find(ENV['BUNDLE_ID'])
  tunes_build = app.builds.find { |build| build.build_version == BUILD_NUMBER }
  build = TestFlight::Build.find(app.apple_id, tunes_build.id)
  client = build.client

  build.test_info.whats_new = "some new shit for build #{BUILD_NUMBER}"
  build.export_compliance.encryption_updated = false
  build.beta_review_info.demo_account_required = false
  resp = client.post_for_review(app.apple_id, tunes_build.id, build)

  # if distribute to external?
  group = TestFlight::Group.default_external_group(app.apple_id)
  resp = client.add_group_to_build(app.apple_id, group.id, tunes_build.id)

  0
end

# def get_new_build_info_for_review(client: nil, app_id: nil, build_id: nil)
#   url = "/testflight/v2/providers/#{team_id}/apps/#{app_id}/builds/#{build_id}"
#   r = client.request(:get) do |req|
#     req.url url
#     req.headers['Content-Type'] = 'application/json'
#   end

#   r.body['data']
# end

# def post_test_info(client: nil, app_id: nil)
#   url = "/testflight/v2/providers/#{team_id}/apps/#{app_id}/testInfo"
#   r = client.request(:put) do |req|
#     req.url url
#     req.body = {
#       primaryLocale: "en-US",
#       details: [{
#         locale: "en-US",
#         feedbackEmail: "mnpirri@gmail.com",
#         marketingUrl: nil,
#         privacyPolicyUrl: nil,
#         privacyPolicy: nil,
#         description: nil
#       }],
#       eula: nil,
#       betaReviewInfo: {
#         contactFirstName: "First Name",
#         contactLastName: "Last Name",
#         contactPhone: "0987654321",
#         contactEmail: "Email",
#         demoAccountName: "User Name",
#         demoAccountPassword: "Password",
#         demoAccountRequired: true,
#         notes: "notes!"
#       }
#     }.to_json
#     req.headers['Content-Type'] = 'application/json'
#   end
# end

# def start_app_review(client: nil, app_id: nil, build_id: nil, build_info: nil)
#   url = "/testflight/v2/providers/#{team_id}/apps/#{app_id}/builds/#{build_id}/review"
#   r = client.request(:post) do |req|
#     req.url url
#     req.body = build_info.to_json()
#     req.headers['Content-Type'] = 'application/json'
#   end
# end

# task :yolo2 do
#   require 'spaceship'
#   Spaceship::Tunes.login("mnpirri@gmail.com")
#   app = Spaceship::Tunes::Application.find("com.markpirri.pilot-tst")

#   build = app.builds.find { |build| build.build_version == "2" }

#   userDetailsData = build.client.user_details_data
#   teamId = userDetailsData['contentProviderId']

#   post_test_info(client: build.client, app_id: build.build_train.application.apple_id)

#   info = get_new_build_info_for_review(client: build.client, app_id: build.build_train.application.apple_id, build_id: build.id)
#   start_app_review(client: build.client, app_id: build.build_train.application.apple_id, build_id: build.id, build_info: info)

#   require 'pry'
#   binding.pry
#   puts 'hi'

#   # build.update_build_information!(whats_new: "new stuff", description: "app description", feedback_email: "feedback@email.org")

#   # build.client.submit_testflight_build_for_review!(
#   #         app_id: build.build_train.application.apple_id,
#   #         marketing_url: "http://www.apple.com",
#   #         changelog: "changes",
#   #         train: build.build_train.version_string,
#   #         build_number: build.id,
#   #         platform: build.platform,
#   #         feedback_email: "hi@there.com"
#   #       )

#   #  build.build_train.update_testing_status!(true, 'external', build)

# end

task :rubygems_admins do
  names = ["KrauseFx", "ohayon", "asfalcone", "mpirri", "mfurtak", "milch"]
  (GEMS + ["krausefx-shenzhen", "commander-fastlane"]).each do |gem_name|
    names.each do |name|
      puts `gem owner #{gem_name} -a #{name}`
    end
  end
end

task :test_all do
  formatter = "--format progress"
  formatter += " -r rspec_junit_formatter --format RspecJunitFormatter -o $CIRCLE_TEST_REPORTS/rspec/fastlane-junit-results.xml" if ENV["CIRCLE_TEST_REPORTS"]
  sh "rspec --pattern ./**/*_spec.rb #{formatter}"
end

# Overwrite the default rake task
# since we use fastlane to deploy fastlane
task :push do
  sh "bundle exec fastlane release"
end

#####################################################
# @!group Helper Methods
#####################################################

def box(str)
  l = str.length + 4
  puts ''
  puts '=' * l
  puts '| ' + str + ' |'
  puts '=' * l
end

task default: :test_all
