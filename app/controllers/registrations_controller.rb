class RegistrationsController < ApplicationController
  before_action :require_logout, only: [ :new, :create ]

  def new
    @user = User.new
    render layout: "auth"
  end

  def create
    @user = User.new(user_params)
    @user.theme_name ||= User.default_theme

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Welcome to Yayo Studio! The grid expands."
    else
      render :new, layout: "auth", status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
