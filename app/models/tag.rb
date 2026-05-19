class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :alphabetical, -> { order(name: :asc) }
end
