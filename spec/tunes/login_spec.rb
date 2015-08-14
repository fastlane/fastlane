require 'spec_helper'

describe Spaceship::Tunes do
  describe "login" do
    it "works with valid data and uses the correct cookies afterwards" do
      client = Spaceship::Tunes.login
      cookies = client.cookie.split(';')

      expect(cookies.count).to eq(4)
      expect(cookies[0]).to include("myacinfo=DAWTKN") # this is actually longer
      expect(cookies[1]).to eq("woinst=3363")
      expect(cookies[2]).to eq("itctx=abc:def")
      expect(cookies[3]).to eq("wosid=xBJMOVttbAQ1Cwlt8ktafw")
    end
  end
end
