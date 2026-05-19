class SettingsController < ApplicationController
  before_action :require_login

  def show
    @themes = Theme.all
  end

  def update
    current_user.update!(settings_params)
    redirect_to settings_path, notice: "Settings saved"
  end

  private

  def settings_params
    params.require(:user).permit(:name, :email, :theme_name)
  end
end
