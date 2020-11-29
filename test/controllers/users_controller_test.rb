require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count
      user = users(:kari)

      perform_login(user)
      must_redirect_to root_path
      expect(session[:user_id]).must_equal  user.id

      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do

      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      perform_login(user)

      must_redirect_to root_path

      # Should have created a new user this time
      expect(User.count).must_equal start_count + 1

      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count

      # existing user dan has uid "12345"
      fake_dan = User.new(provider: "github", uid: "12345", username: "not_dan", email: "faker@user.com")

      user = perform_login(fake_dan)

      # user must not have been valid, because uid already exists, with different username & email
      expect(user.valid?).must_equal false

      # Should *not* have created a new user
      expect(User.count).must_equal start_count

      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create user account #{user.errors.messages}"

      expect(user.errors.messages[:uid]).must_equal ["has already been taken"]
    end
  end
end
