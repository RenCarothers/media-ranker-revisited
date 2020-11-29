require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:dan)
      expect(dan).must_respond_to :votes
      dan.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      expect(dan).must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end

    it "requires a unique uid" do
      dan = users(:dan)

      dup = User.new(username: "fake_dan", provider: "github", uid: 12345, email: "ada@adadevelopersacademy.org")
      expect(dup.valid?).must_equal false
      expect(dup.errors.messages).must_include :uid
    end
  end

  describe "custom methods" do
    describe "build from github" do
      let (:new_user) {
        {
            uid: "1337",
            provider: "github",
            info: {
                username: "username",
                name: "name",
                email: "email@email.com",
                avatar: nil
            }
        }
      }

      it "can successfully build a user from a given auth_hash" do

        user = User.build_from_github(new_user)

        puts user.inspect
        expect(user.valid?).must_equal true
        expect(user.uid).must_equal new_user[:uid]
        expect(user.provider).must_equal new_user[:provider]
        expect(user.username).must_equal new_user[:info][:name]
        expect(user.email).must_equal new_user[:info][:email]
      end
    end

  end
end
