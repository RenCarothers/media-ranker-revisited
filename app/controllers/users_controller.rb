class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"] # how gets info about user's github
    user = User.find_by(uid: auth_hash[:uid], provider: params[:provider], email: auth_hash[:info][:email], username: auth_hash[:info][:name])
    if user # exists
      flash[:status] = :success
      flash[:result_text] = "Existing user #{user.username} is logged in."
    else # user doesn't exist yet
         # call helper function
    user = User.build_from_github(auth_hash)
      if user.valid?
        user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.username}"
      else
        flash[:status] = :failure
        flash[:result_text] = "Could not create user account #{user.errors.messages}"
        return redirect_to root_path
      end
    end
    session[:user_id] = user.id
    redirect_to root_path
  end

  # def login_form
  # end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end

  private

  def strong_user_params # TODO: Currently unused. Not sure how to incorporate these into the create method?
    return params.require(:user).permit(:username, :uid, :email, :provider, :avatar)
  end
end
