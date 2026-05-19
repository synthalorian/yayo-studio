class ThemesController < ApplicationController
  before_action :require_login

  def update
    if params[:theme_id].present?
      theme = Theme.find(params[:theme_id])
      current_user.update!(theme_name: theme.name)
      redirect_back fallback_location: dashboard_path,
                    notice: "Theme switched to '#{theme.name}'"
    elsif params[:colors].present?
      theme = current_user.themes.create!(
        name: "Custom #{Date.current}",
        colors: params[:colors].permit!.to_h,
        is_system: false
      )
      current_user.update!(theme_name: theme.name)
      redirect_back fallback_location: dashboard_path,
                    notice: "Custom theme created and applied!"
    else
      redirect_back fallback_location: dashboard_path, alert: "No theme specified"
    end
  end
end
