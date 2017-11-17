# describe Spaceship::Tunes::BuildTrain do
#   before { Spaceship::Tunes.login }
#   subject { Spaceship::Tunes.client }
#   let(:username) { 'spaceship@krausefx.com' }
#   let(:password) { 'so_secret' }

#   describe "properly parses the train" do
#     let(:app) { Spaceship::Application.all.first }

#     it "inspect works" do
#       expect(Spaceship::Application.all.first.build_trains.values.first.inspect).to include("Tunes::BuildTrain")
#     end

#     it "works filled in all required values (appletvos)" do
#       trains = app.build_trains(platform: 'appletvos')

#       expect(trains.count).to eq(2)
#       train = trains.values.first

#       expect(train.version_string).to eq("1.0")
#       expect(train.platform).to eq("appletvos")
#       expect(train.application).to eq(app)

#       # TestFlight
#       expect(trains.values.first.external_testing_enabled).to eq(false)
#       expect(trains.values.first.internal_testing_enabled).to eq(true)
#       expect(trains.values.last.external_testing_enabled).to eq(false)
#       expect(trains.values.last.internal_testing_enabled).to eq(false)
#     end

#     it "works filled in all required values (ios)" do
#       trains = app.build_trains(platform: 'ios')

#       expect(trains.count).to eq(2)
#       train = trains.values.first

#       expect(train.version_string).to eq("1.0")
#       expect(train.platform).to eq("ios")
#       expect(train.application).to eq(app)

#       # TestFlight
#       expect(trains.values.first.external_testing_enabled).to eq(false)
#       expect(trains.values.first.internal_testing_enabled).to eq(true)
#       expect(trains.values.last.external_testing_enabled).to eq(false)
#       expect(trains.values.last.internal_testing_enabled).to eq(false)
#     end

#     it "returns all processing builds (ios)" do
#       builds = app.all_processing_builds(platform: 'ios')
#       expect(builds.count).to eq(3)
#     end

#     it "returns all processing builds (tvos)" do
#       builds = app.all_processing_builds(platform: 'appletvos')
#       expect(builds.count).to eq(3)
#     end

#     describe "Accessing builds (ios)" do
#       it "lets the user fetch the builds for a given train" do
#         train = app.build_trains(platform: 'ios').values.first
#         expect(train.builds.count).to eq(1)
#       end

#       it "lets the user fetch the builds using the version as a key" do
#         train = app.build_trains(platform: 'ios')['1.0']
#         expect(train.version_string).to eq('1.0')
#         expect(train.platform).to eq('ios')
#         expect(train.internal_testing_enabled).to eq(true)
#         expect(train.external_testing_enabled).to eq(false)
#         expect(train.builds.count).to eq(1)
#       end
#     end

#     describe "Accessing builds (tvos)" do
#       it "lets the user fetch the builds for a given train" do
#         train = app.build_trains(platform: 'appletvos').values.first
#         expect(train.builds.count).to eq(1)
#       end

#       it "lets the user fetch the builds using the version as a key" do
#         train = app.build_trains['1.0']
#         expect(train.version_string).to eq('1.0')
#         expect(train.platform).to eq('appletvos')
#         expect(train.internal_testing_enabled).to eq(true)
#         expect(train.external_testing_enabled).to eq(false)
#         expect(train.builds.count).to eq(1)
#       end
#     end

#     describe "Processing builds (ios)" do
#       it "properly extracted the processing builds from a train" do
#         train = app.build_trains(platform: 'ios')['1.0']
#         expect(train.platform).to eq('ios')
#         expect(train.processing_builds.count).to eq(0)
#       end
#     end

#     describe "Processing builds (tvos)" do
#       it "properly extracted the processing builds from a train" do
#         train = app.build_trains(platform: 'appletvos')['1.0']
#         expect(train.platform).to eq('appletvos')
#         expect(train.processing_builds.count).to eq(0)
#       end
#     end

#     describe "#update_testing_status (ios)" do
#       it "just works (tm)" do
#         train1 = app.build_trains(platform: 'ios')['1.0']
#         train2 = app.build_trains(platform: 'ios')['1.1']
#         expect(train1.platform).to eq('ios')
#         expect(train2.platform).to eq('ios')
#         expect(train1.internal_testing_enabled).to eq(true)
#         expect(train2.internal_testing_enabled).to eq(false)

#         train2.update_testing_status!(true, 'internal')

#         expect(train2.internal_testing_enabled).to eq(true)
#       end
#     end

#     describe "#update_testing_status (tvos)" do
#       it "just works (tm)" do
#         train1 = app.build_trains(platform: 'appletvos')['1.0']
#         train2 = app.build_trains(platform: 'appletvos')['1.1']
#         expect(train1.platform).to eq('appletvos')
#         expect(train2.platform).to eq('appletvos')
#         expect(train1.internal_testing_enabled).to eq(true)
#         expect(train2.internal_testing_enabled).to eq(false)

#         train2.update_testing_status!(true, 'internal')

#         expect(train2.internal_testing_enabled).to eq(true)
#       end
#     end
#   end
# end
