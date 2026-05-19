class ProjectsController < ApplicationController
  before_action :require_login
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = current_user.projects.includes(:project_type, :tags).by_status
    @project_types = ProjectType.ordered
    @active_type = params[:type]
    if @active_type.present?
      @projects = @projects.joins(:project_type).where(project_types: { name: @active_type })
    end
  end

  def show
    @journal_entries = @project.journal_entries.includes(:tags).recent.limit(10)
    @assets = @project.assets.by_type
    @ai_integrations = @project.ai_integrations.enabled
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to @project, notice: "#{@project.name} initialized. The grid grows."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "#{@project.name} has been archived to the void"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :project_type_id, :status, :repo_url, :website_url, :config)
  end
end
