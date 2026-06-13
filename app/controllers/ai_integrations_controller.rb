class AiIntegrationsController < ApplicationController
  before_action :require_login
  before_action :set_project, except: [ :global, :discover, :harness_fields ]

  # Global harness dashboard — all integrations across all projects
  def global
    @integrations = AiIntegration.joins(:project)
                                  .where(projects: { user_id: current_user.id })
                                  .includes(:project)
                                  .by_harness
    @by_status = @integrations.group_by(&:health_status)
    @harness_categories = HarnessRegistry.categories
    @discovered = HarnessRegistry.auto_discover!
    @harnesses = HarnessRegistry.all
  end

  # Auto-discover harnesses and create integrations
  def discover
    discovered = HarnessRegistry.auto_discover!
    created = []

    discovered.each do |entry|
      next if AiIntegration.joins(:project)
                            .where(projects: { user_id: current_user.id })
                            .exists?(harness_type: entry[:harness])

      # Find or create a project for unassigned harnesses
      project = current_user.projects.find_or_create_by!(name: entry[:harness].titleize) do |p|
        p.description = "#{entry[:harness]} AI harness — auto-discovered"
        p.project_type = ProjectType.find_by(name: "AI") || ProjectType.first
        p.status = "active"
      end

      harness_def = HarnessRegistry.find(entry[:harness])
      integration = project.ai_integrations.create!(
        name: harness_def&.name || entry[:harness].titleize,
        provider: entry[:harness].split("-").first,
        harness_type: entry[:harness],
        status: "connected",
        enabled: true,
        config: {
          "cli_path" => entry[:path],
          "version" => entry[:version],
          "auto_discovered" => true
        }
      )
      created << integration
    end

    redirect_to ai_harnesses_path,
                notice: "Discovered #{discovered.size} harnesses. #{created.size} new integrations created."
  end

  def new
    @integration = @project.ai_integrations.build
    @harness_type = params[:harness_type]
    @harness_def = HarnessRegistry.find(@harness_type) if @harness_type
    @harnesses = HarnessRegistry.all
  end

  def create
    integration_params = build_integration_params
    @integration = @project.ai_integrations.build(integration_params)
    @integration.enabled = true if @integration.enabled.nil?

    if @integration.save
      @integration.check_health!
      redirect_to project_ai_integrations_path(@project),
                  notice: "⚡ #{@integration.display_name} connected to #{@project.name}"
    else
      @harness_def = HarnessRegistry.find(@integration.harness_type)
      @harnesses = HarnessRegistry.all
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @integrations = @project.ai_integrations.by_harness
  end

  def show
    @integration = @project.ai_integrations.find(params[:id])
  end

  def edit
    @integration = @project.ai_integrations.find(params[:id])
    @harness_def = @integration.harness_definition
    @harnesses = HarnessRegistry.all
  end

  def update
    @integration = @project.ai_integrations.find(params[:id])
    integration_params = build_integration_params
    if @integration.update(integration_params)
      redirect_to project_ai_integrations_path(@project),
                  notice: "#{@integration.display_name} updated"
    else
      @harness_def = @integration.harness_definition
      @harnesses = HarnessRegistry.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @integration = @project.ai_integrations.find(params[:id])
    name = @integration.display_name
    @integration.destroy
    redirect_to project_ai_integrations_path(@project),
                notice: "#{name} disconnected from the grid"
  end

  def check
    @integration = @project.ai_integrations.find(params[:id])
    status = @integration.check_health!
    status_icon = case status
    when "connected" then "🟢"
    when "disconnected" then "🔴"
    when "error" then "🟡"
    else "⚪"
    end
    redirect_back fallback_location: project_ai_integrations_path(@project),
                  notice: "#{status_icon} #{@integration.display_name}: #{status}"
  end

  def launch
    @integration = @project.ai_integrations.find(params[:id])
    cmd = @integration.launch_command
    if cmd
      # Log the launch attempt — actual spawning happens in the terminal
      redirect_back fallback_location: project_ai_integrations_path(@project),
                    notice: "🚀 Launch command for #{@integration.display_name}: #{cmd}"
    else
      redirect_back fallback_location: project_ai_integrations_path(@project),
                    alert: "#{@integration.display_name} has no launch command configured"
    end
  end

  # AJAX endpoint for dynamic harness config fields
  def harness_fields
    @harness_def = HarnessRegistry.find(params[:harness_type])
    @integration = AiIntegration.new(harness_type: params[:harness_type])

    render partial: "harness_fields", locals: {
      harness_def: @harness_def,
      integration: @integration,
      f: nil  # Not in a form context for this partial
    }
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def build_integration_params
    permitted = params.require(:ai_integration).permit(
      :name, :provider, :harness_type, :enabled,
      config: {}
    )

    # If harness_type is set but provider isn't, derive it
    if permitted[:harness_type].present? && permitted[:provider].blank?
      harness_def = HarnessRegistry.find(permitted[:harness_type])
      permitted[:provider] = harness_def&.key&.split("-")&.first || "custom"
    end

    # Parse JSON config fields if they come as strings
    if params[:ai_integration][:config].is_a?(ActionController::Parameters)
      config = permitted[:config] || {}
      HarnessRegistry.find(permitted[:harness_type])&.config_schema&.dig(:fields)&.each do |field|
        next unless field[:type] == "number" || field[:type] == "boolean"
        key = field[:key]
        next unless config[key].present?
        config[key] = field[:type] == "number" ? config[key].to_f : ActiveModel::Type::Boolean.new.cast(config[key])
      end
    end

    permitted
  end
end
