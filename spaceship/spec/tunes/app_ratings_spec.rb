describe Spaceship::Tunes::AppRatings do
  before { Spaceship::Tunes.login }
  let(:app) { Spaceship::Application.all.first }
  let(:client) { Spaceship::Application.client }

  describe "successfully loads rating summary" do
    it "contains the right information" do
      TunesStubbing.itc_stub_ratings

      expect(app.ratings.rating_count).to eq(1457)
      expect(app.ratings.one_star_rating_count).to eq(219)
      expect(app.ratings.two_star_rating_count).to eq(67)
      expect(app.ratings.three_star_rating_count).to eq(174)
      expect(app.ratings.four_star_rating_count).to eq(393)
      expect(app.ratings.five_star_rating_count).to eq(604)

      expect(app.ratings(storefront: "US").rating_count).to eq(1300)
    end
  end

  describe "successfully calculates the average" do
    it "the average is correct" do
      TunesStubbing.itc_stub_ratings

      expect(app.ratings.average_rating).to eq(3.75)
      expect(app.ratings(storefront: "US").average_rating).to eq(4.34)
    end
  end

  describe "successfully loads reviews" do
    it "contains the right information" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings
      reviews = ratings.reviews("US")

      expect(reviews.count).to eq(4)
      expect(reviews.first.store_front).to eq("NZ")
      expect(reviews.first.id).to eq(1_000_000_000)
      expect(reviews.first.rating).to eq(2)
      expect(reviews.first.title).to eq("Title 1")
      expect(reviews.first.review).to eq("Review 1")
      expect(reviews.first.last_modified).to eq(1_463_887_020_000)
      expect(reviews.first.nickname).to eq("Reviewer1")
    end

    it "contains the right information with version id" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings
      reviews = ratings.reviews("", "1")

      expect(reviews.count).to eq(4)
      expect(reviews.first.store_front).to eq("NZ")
      expect(reviews.first.id).to eq(1_000_000_000)
      expect(reviews.first.rating).to eq(2)
      expect(reviews.first.title).to eq("Title 1")
      expect(reviews.first.review).to eq("Review 1")
      expect(reviews.first.last_modified).to eq(1_463_887_020_000)
      expect(reviews.first.nickname).to eq("Reviewer1")
    end

    it "contains the right information with upto_date" do
      TunesStubbing.itc_stub_ratings
      ratings = app.ratings
      reviews = ratings.reviews("US", "", "2016-03-27")

      expect(reviews.count).to eq(2)
      expect(reviews.first.store_front).to eq("NZ")
      expect(reviews.first.id).to eq(1_000_000_000)
      expect(reviews.first.rating).to eq(2)
      expect(reviews.first.title).to eq("Title 1")
      expect(reviews.first.review).to eq("Review 1")
      expect(reviews.first.last_modified).to eq(1_463_887_020_000)
      expect(reviews.first.nickname).to eq("Reviewer1")

      expect(reviews.last.store_front).to eq("NZ")
      expect(reviews.last.id).to eq(1_000_000_001)
      expect(reviews.last.rating).to eq(2)
      expect(reviews.last.title).to eq("Title 2")
      expect(reviews.last.review).to eq("Review 2")
      expect(reviews.last.last_modified).to eq(1_459_152_540_000)
      expect(reviews.last.nickname).to eq("Reviewer2")
    end
  end

  describe "Manages Developer Response" do
    it "Can Read Response" do
      TunesStubbing.itc_stub_ratings
      review = app.ratings.reviews("US").first
      expect(review.responded?).to eq(true)
      expect(review.developer_response.response).to eq("Thank You")
    end
  end
end
