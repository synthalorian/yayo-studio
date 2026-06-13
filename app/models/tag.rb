class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }

  scope :alphabetical, -> { order(name: :asc) }
end
