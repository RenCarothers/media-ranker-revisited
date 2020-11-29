require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count

      # Get a user from the fixtures to represent existing user
      user = users(:kari)

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Send a login request for that user
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Check that the user ID was set as expected
      expect(session[:user_id]).must_equal user.id

      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do

      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Should have created a new user this time
      expect(User.count).must_equal start_count + 1

      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
    end
  end
end
