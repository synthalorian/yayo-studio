class Project < ApplicationRecord
  belongs_to :user
  belongs_to :project_type

  has_many :journal_entries, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :ai_integrations, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true
  validates :repo_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL", allow_blank: true }
  validates :website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL", allow_blank: true }

  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :by_status, -> { order(Arel.sql("CASE status WHEN 'active' THEN 0 WHEN 'paused' THEN 1 ELSE 2 END, updated_at DESC")) }

  STATUSES = %w[active paused archived planning].freeze

  validates :status, inclusion: { in: STATUSES, allow_blank: true }
end
