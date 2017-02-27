describe Spaceship::Tunes::AppRatings do
  before { Spaceship::Tunes.login }
  let(:app) { Spaceship::Application.all.first }

  describe "successfully loads rating summary" do
    it "contains the right information" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings

      expect(ratings.versions.count).to eq(24)
      expect(ratings.store_fronts.count).to eq(4)
      expect(ratings.rating_summary.review_count).to eq(75)
      expect(ratings.rating_summary.rating_count).to eq(124)
      expect(ratings.rating_summary.one_star_rating_count).to eq(36)
      expect(ratings.rating_summary.two_star_rating_count).to eq(20)
      expect(ratings.rating_summary.three_star_rating_count).to eq(9)
      expect(ratings.rating_summary.four_star_rating_count).to eq(13)
      expect(ratings.rating_summary.five_star_rating_count).to eq(46)

      expect(ratings.store_fronts["US"].review_count).to eq(66)
    end
  end

  describe "successfully calculates the average" do
    it "the average is correct" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings

      expect(ratings.rating_summary.average_rating).to eq(3.1)
      expect(ratings.store_fronts["US"].average_rating).to eq(3.25)
    end
  end

  describe "successfully loads reviews" do
    it "contains the right information" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings
      reviews = ratings.reviews("US")

      expect(reviews.count).to eq(4)
      expect(reviews.first).to eq({
        "id" => 1_000_000_000,
        "rating" => 2,
        "title" => "Title 1",
        "review" => "Review 1",
        "created" => 1_463_887_020_000,
        "nickname" => "Reviewer1",
        "storeFront" => "NZ"
      })
    end
  end
end
