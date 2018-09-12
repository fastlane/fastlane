require 'deliver/submit_for_review'
require 'ostruct'

describe Deliver::SubmitForReview do
  let(:review_submitter) { Deliver::SubmitForReview.new }

  # Create a fake app with number_of_builds candidate builds
  # the builds will be in date ascending order
  def make_fake_builds(number_of_builds)
    (0...number_of_builds).map do |num|
      OpenStruct.new({ upload_date: Time.now.utc + 60 * num }) # minutes_from_now
    end
  end

  def make_fake_version
    return OpenStruct.new({})
  end

  def make_fake_candidates(number_of_candidates)
    (0...number_of_candidates).map do |num|
      OpenStruct.new({})
    end
  end

  describe :find_build do
    context 'one build' do
      let(:fake_builds) { make_fake_builds(1) }
      it 'finds the one build' do
        allow(review_submitter).to receive(:wait_for_candidate).and_return(fake_builds)
        only_build = fake_builds.first
        expect(review_submitter.find_build(make_fake_version)).to eq(only_build)
      end
    end

    context 'two builds' do
      let(:fake_builds) { make_fake_builds(2) }
      it 'finds the one build' do
        allow(review_submitter).to receive(:wait_for_candidate).and_return(fake_builds)
        newest_build = fake_builds.last
        expect(review_submitter.find_build(make_fake_version)).to eq(newest_build)
      end
    end
  end

  describe :wait_for_candidate do
    context 'has the candidate immediately' do
      let(:fake_candidates) { make_fake_candidates(2) }
      it 'returns all candidates' do
        fake_version = make_fake_version
        allow(fake_version).to receive(:candidate_builds).and_return(fake_candidates)
        expect(review_submitter.wait_for_candidate(fake_version)).to eq(fake_candidates)
      end
    end

    context 'waits for candidates for more than 5 minutes' do
      let(:fake_candidates) { make_fake_candidates(0) }
      let(:time_now) { Time.now }
      # Stub Time.now to return current time on first call and 6 minutes later on second
      before { allow(Time).to receive(:now).and_return(time_now, (time_now + 60 * 6)) }
      it 'throws a UI error' do
        fake_version = make_fake_version
        allow(fake_version).to receive(:candidate_builds).and_return(fake_candidates)
        expect do
          review_submitter.wait_for_candidate(fake_version)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not find any available candidate builds on App Store Connect to submit")
      end
    end
  end
end
