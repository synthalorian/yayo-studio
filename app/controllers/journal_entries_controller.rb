class JournalEntriesController < ApplicationController
  before_action :require_login
  before_action :set_project, except: [ :index ]

  def index
    @entries = JournalEntry.joins(:project)
                            .where(projects: { user_id: current_user.id })
                            .includes(:project, :tags)
                            .recent
    @entries = @entries.tagged_with(params[:tag]) if params[:tag].present?
  end

  def show
    @entry = @project.journal_entries.find(params[:id])
  end

  def new
    @entry = @project.journal_entries.build
  end

  def create
    @entry = @project.journal_entries.build(entry_params)
    if @entry.save
      redirect_to [ @project, @entry ], notice: "Entry saved to the timeline"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entry = @project.journal_entries.find(params[:id])
  end

  def update
    @entry = @project.journal_entries.find(params[:id])
    if @entry.update(entry_params)
      redirect_to [ @project, @entry ], notice: "Entry updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry = @project.journal_entries.find(params[:id])
    @entry.destroy
    redirect_to @project, notice: "Entry deleted"
  end

  def search
    query = params[:q].to_s.strip
    @entries = @project.journal_entries
                        .with_rich_text_content
                        .where("title ILIKE :q", q: "%#{query}%")
                        .recent
    render partial: "entries_list", locals: { entries: @entries }
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def entry_params
    params.require(:journal_entry).permit(:title, :content, :entry_date, tag_ids: [])
  end
end
