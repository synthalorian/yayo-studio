class AssetsController < ApplicationController
  before_action :require_login
  before_action :set_project

  def new
    @asset = @project.assets.build
  end

  def create
    @asset = @project.assets.build(asset_params)
    if @asset.save
      redirect_to @project, notice: "Asset added to the library"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @asset = @project.assets.find(params[:id])
  end

  def update
    @asset = @project.assets.find(params[:id])
    if @asset.update(asset_params)
      redirect_to @project, notice: "Asset updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset = @project.assets.find(params[:id])
    @asset.destroy
    redirect_to @project, notice: "Asset removed"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def asset_params
    params.require(:asset).permit(:name, :file_path, :asset_type, metadata: {})
  end
end
