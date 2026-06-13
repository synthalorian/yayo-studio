class SessionsController < ApplicationController
  before_action :require_logout, only: [ :new, :create ]

  def new
    render layout: "auth"
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Welcome back to the grid, #{user.name}"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, layout: "auth", status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out. See you on the next wave."
  end
end
