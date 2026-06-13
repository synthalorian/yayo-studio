class DashboardController < ApplicationController
  before_action :require_login

  def show
    @projects = current_user.projects.includes(:project_type, :tags).by_status
    @recent_entries = JournalEntry.joins(:project)
                                   .where(projects: { user_id: current_user.id })
                                   .includes(:project, :tags)
                                   .with_rich_text_content
                                   .recent
                                   .limit(5)
    @stats = {
      total: @projects.size,
      active: @projects.active.size,
      archived: @projects.archived.size,
      entries: JournalEntry.joins(:project)
                             .where(projects: { user_id: current_user.id })
                             .count
    }
  end
end
