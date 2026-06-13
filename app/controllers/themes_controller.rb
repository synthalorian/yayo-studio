class ThemesController < ApplicationController
  before_action :require_login

  def update
    if params[:theme_id].present?
      theme = Theme.find_by(id: params[:theme_id])
      if theme
        current_user.update!(theme_name: theme.name)
        redirect_back fallback_location: dashboard_path,
                      notice: "Theme switched to '#{theme.name}'"
      else
        redirect_back fallback_location: dashboard_path, alert: "Theme not found"
      end
    elsif params[:colors].present?
      theme = Theme.create!(
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
