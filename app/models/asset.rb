class Asset < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: { maximum: 255 }
  validates :file_path, length: { maximum: 1000 }, allow_blank: true

  scope :by_type, -> { order(asset_type: :asc, name: :asc) }

  TYPES = %w[image audio model document code font other].freeze

  validates :asset_type, inclusion: { in: TYPES, allow_blank: true }
end
