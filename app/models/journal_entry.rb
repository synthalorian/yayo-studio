class JournalEntry < ApplicationRecord
  belongs_to :project

  has_rich_text :content
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true, length: { maximum: 255 }

  scope :recent, -> { order(entry_date: :desc, created_at: :desc) }

  before_save :set_entry_date

  private

  def set_entry_date
    self.entry_date ||= Date.current
  end
end
