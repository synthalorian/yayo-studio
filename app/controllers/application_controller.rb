class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_theme

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

  def logged_in?
    current_user.present?
  end

  def current_theme
    @current_theme ||= if logged_in?
      Theme.find_by(name: current_user.theme_name) || Theme.system.first
    else
      Theme.system.first
    end
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in to access Yayo Studio"
    end
  end

  def require_logout
    if logged_in?
      redirect_to dashboard_path, notice: "You're already logged in"
    end
  end
end
