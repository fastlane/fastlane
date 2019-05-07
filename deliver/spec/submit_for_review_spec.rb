require 'deliver/submit_for_review'
require 'ostruct'

describe Deliver::SubmitForReview do
  let(:review_submitter) { Deliver::SubmitForReview.new }

  # Create a fake app with number_of_builds candidate builds
  # the builds will be in date ascending order
  def make_fake_builds(number_of_builds)
    (0...number_of_builds).map do |num|
      OpenStruct.new({ upload_date: Time.now.utc + 60 * num, processing: false }) # minutes_from_now
    end
  end

  def make_fake_app
    OpenStruct.new({})
  end

  def make_fake_version
    fake_version = double('fake_version')
    allow(fake_version).to receive(:[]).with(:app_version).and_return("1.2.3")
    fake_version
  end

  describe :find_build do
    context 'one build' do
      let(:fake_builds) { make_fake_builds(1) }
      it 'finds the one build' do
        only_build = fake_builds.first
        expect(review_submitter.find_build(fake_builds)).to eq(only_build)
      end
    end

    context 'no builds' do
      let(:fake_builds) { make_fake_builds(0) }
      it 'throws a UI error' do
        expect do
          review_submitter.find_build(fake_builds)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find any available candidate builds on App Store Connect to submit")
      end
    end

    context 'two builds' do
      let(:fake_builds) { make_fake_builds(2) }
      it 'finds the one build' do
        newest_build = fake_builds.last
        expect(review_submitter.find_build(fake_builds)).to eq(newest_build)
      end
    end

    describe :wait_for_build do
      context 'no candidates' do
        let(:fake_app) { make_fake_app }
        let(:fake_version) { make_fake_version }
        let(:time_now) { Time.now }

        # Stub Time.now to return current time on first call and 6 minutes later on second
        before { allow(Time).to receive(:now).and_return(time_now, (time_now + 60 * 6)) }
        it 'throws a UI error' do
          allow(fake_app).to receive(:latest_version).and_return(fake_version)
          allow(fake_version).to receive(:candidate_builds).and_return([])
          expect do
            review_submitter.wait_for_build(fake_app, "1.2.3")
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find any available candidate builds on App Store Connect to submit")
        end
      end

      context 'has candidates and one build' do
        let(:fake_app) { make_fake_app }
        let(:fake_version) { make_fake_version }
        let(:fake_builds) { make_fake_builds(1) }

        it 'finds the one build' do
          allow(fake_app).to receive(:latest_version).and_return(fake_version)
          allow(fake_version).to receive(:candidate_builds).and_return(fake_builds)
          only_build = fake_builds.first
          expect(review_submitter.wait_for_build(fake_app, "1.2.3")).to eq(only_build)
        end
      end

      context 'has candidates and one build, but no app version' do
        let(:fake_app) { make_fake_app }
        let(:fake_builds) do
          build = double('fake_build')
          allow(build).to receive(:train_version).and_return("1.2.3")
          allow(build).to receive(:build_version).and_return(1)
          allow(build).to receive(:upload_date).and_return(1_554_754_590)
          expect(build).to receive(:processing).and_return(true)
          [build]
        end
        let(:fake_builds_with_processed_build) do
          build = double('fake_build')
          allow(build).to receive(:train_version).and_return("1.2.3")
          allow(build).to receive(:build_version).and_return(1)
          allow(build).to receive(:upload_date).and_return(1_554_754_590)
          expect(build).to receive(:processing).and_return(false)
          [build]
        end
        let(:fake_version) do
          fake_version = double('fake_version')
          allow(fake_version).to receive(:app_version).and_return(nil)
          fake_version
        end

        it 'finds the one build when no app version is provided' do
          allow(fake_app).to receive(:latest_version).and_return(fake_version)
          allow(fake_version).to receive(:candidate_builds).and_return(fake_builds, fake_builds_with_processed_build)
          only_build = fake_builds.first
          allow(review_submitter).to receive(:sleep)
          expect(review_submitter.wait_for_build(fake_app, nil)).to equal(fake_builds_with_processed_build.first)
        end
      end

      context 'has candidates and one build with a leading zero in the train version' do
        let(:fake_app) { make_fake_app }
        let(:fake_builds) do
          build = double('fake_build')
          expect(build).to receive(:train_version).and_return("1.02.3")
          allow(build).to receive(:build_version).and_return(1)
          allow(build).to receive(:upload_date).and_return(1_554_754_590)
          allow(build).to receive(:processing).and_return(false)
          [build]
        end
        let(:fake_builds_with_trimmed_zero) do
          build = double('fake_build_with_trimmed_zero')
          expect(build).to receive(:train_version).and_return("1.2.3")
          allow(build).to receive(:build_version).and_return(1)
          allow(build).to receive(:upload_date).and_return(1_554_754_590)
          allow(build).to receive(:processing).and_return(true)
          [build]
        end
        let(:fake_version) do
          fake_version = double('fake_version')
          allow(fake_version).to receive(:[]).with(:app_version).and_return("1.02.3")
          fake_version
        end

        it 'does not find the one build until the candidate is corrected' do
          allow(fake_app).to receive(:latest_version).and_return(fake_version)
          allow(fake_version).to receive(:candidate_builds).and_return(fake_builds_with_trimmed_zero, fake_builds_with_trimmed_zero, fake_builds)
          allow(review_submitter).to receive(:sleep)
          expect(review_submitter.wait_for_build(fake_app, "1.02.3")).to equal(fake_builds.first)
        end
      end
    end
  end
end
