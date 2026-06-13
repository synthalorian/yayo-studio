class ProjectType < ApplicationRecord
  has_many :projects, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :position, numericality: { allow_nil: true, only_integer: true }

  scope :ordered, -> { order(position: :asc, name: :asc) }

  ICONS = {
    "Game" => "🎮",
    "Music" => "🎵",
    "Code" => "💻",
    "Writing" => "✍️",
    "Art" => "🎨",
    "Design" => "🎯",
    "System" => "🔧",
    "Video" => "🎬",
    "AI" => "🤖",
    "Other" => "📁"
  }.freeze

  def default_icon
    ICONS[name] || "📁"
  end
end
