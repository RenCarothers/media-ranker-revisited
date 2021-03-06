class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :current_user

  def render_404
    return render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def current_user
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    end
  end

  def require_login
    if @current_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to do that"
      redirect_to root_path
    end
  end
end
