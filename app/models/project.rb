class Project < ApplicationRecord
  belongs_to :user
  belongs_to :project_type, optional: true

  has_many :journal_entries, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :ai_integrations, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :name, presence: true

  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :by_status, -> { order(Arel.sql("CASE status WHEN 'active' THEN 0 WHEN 'paused' THEN 1 ELSE 2 END, updated_at DESC")) }

  STATUSES = %w[active paused archived planning].freeze

  validates :status, inclusion: { in: STATUSES, allow_blank: true }
end
