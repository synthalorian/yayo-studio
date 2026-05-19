class Asset < ApplicationRecord
  belongs_to :project

  validates :name, presence: true

  scope :by_type, -> { order(asset_type: :asc, name: :asc) }

  TYPES = %w[image audio model document code font other].freeze

  validates :asset_type, inclusion: { in: TYPES, allow_blank: true }
end
