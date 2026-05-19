class DashboardController < ApplicationController
  before_action :require_login

  def show
    @projects = current_user.projects.includes(:project_type, :tags).by_status
    @recent_entries = JournalEntry.joins(:project)
                                   .where(projects: { user_id: current_user.id })
                                   .includes(:project)
                                   .recent
                                   .limit(5)
    @stats = {
      total: @projects.count,
      active: @projects.active.count,
      archived: @projects.archived.count,
      entries: JournalEntry.joins(:project)
                           .where(projects: { user_id: current_user.id })
                           .count
    }
  end
end
