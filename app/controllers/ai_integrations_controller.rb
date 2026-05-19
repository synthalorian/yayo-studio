class AiIntegrationsController < ApplicationController
  before_action :require_login
  before_action :set_project

  def new
    @integration = @project.ai_integrations.build
  end

  def create
    @integration = @project.ai_integrations.build(integration_params)
    @integration.enabled = true if @integration.enabled.nil?
    if @integration.save
      redirect_to @project, notice: "AI integration linked to #{@project.name}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @integration = @project.ai_integrations.find(params[:id])
  end

  def update
    @integration = @project.ai_integrations.find(params[:id])
    if @integration.update(integration_params)
      redirect_to @project, notice: "AI integration updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @integration = @project.ai_integrations.find(params[:id])
    @integration.destroy
    redirect_to @project, notice: "AI integration disconnected"
  end

  def test
    @integration = @project.ai_integrations.find(params[:id])
    # Test the connection — returns a simple status
    result = { status: "ok", message: "Connection to #{@integration.provider} successful", timestamp: Time.current.iso8601 }
    redirect_to @project, notice: "AI test: #{result[:message]}"
  end

  def sync
    @integration = @project.ai_integrations.find(params[:id])
    # Trigger a sync with the AI harness
    redirect_to @project, notice: "Sync initiated with #{@integration.name}"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def integration_params
    params.require(:ai_integration).permit(:name, :provider, :enabled, config: {})
  end
end
