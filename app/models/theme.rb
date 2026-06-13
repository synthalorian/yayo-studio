class Theme < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :colors, presence: true

  scope :system, -> { where(is_system: true) }
  scope :custom, -> { where(is_system: [ false, nil ]) }

  # Define the color palette keys used across all themes
  PALETTE_KEYS = %w[
    background surface surface_alt primary secondary accent
    text text_muted border success warning error
    gradient_start gradient_end
  ].freeze

  def self.seed_system_themes!
    return if system.any?

    themes = {
      "synthwave-84" => {
        name: "Synthwave '84",
        is_system: true,
        colors: {
          "background" => "#0a0a1a",
          "surface" => "#1a0a2e",
          "surface_alt" => "#2d1b4e",
          "primary" => "#b388ff",
          "secondary" => "#00e5ff",
          "accent" => "#ff6ec7",
          "text" => "#e0d0f0",
          "text_muted" => "#7a5f9a",
          "border" => "#3d2a5e",
          "success" => "#00e676",
          "warning" => "#ffab00",
          "error" => "#ff5252",
          "gradient_start" => "#b388ff",
          "gradient_end" => "#00e5ff"
        }
      },
      "dark" => {
        name: "Dark",
        is_system: true,
        colors: {
          "background" => "#0f0f0f",
          "surface" => "#1a1a2e",
          "surface_alt" => "#25253e",
          "primary" => "#6366f1",
          "secondary" => "#22d3ee",
          "accent" => "#f472b6",
          "text" => "#e2e8f0",
          "text_muted" => "#64748b",
          "border" => "#334155",
          "success" => "#22c55e",
          "warning" => "#eab308",
          "error" => "#ef4444",
          "gradient_start" => "#6366f1",
          "gradient_end" => "#22d3ee"
        }
      },
      "light" => {
        name: "Light",
        is_system: true,
        colors: {
          "background" => "#ffffff",
          "surface" => "#f8fafc",
          "surface_alt" => "#f1f5f9",
          "primary" => "#6366f1",
          "secondary" => "#0891b2",
          "accent" => "#db2777",
          "text" => "#0f172a",
          "text_muted" => "#64748b",
          "border" => "#e2e8f0",
          "success" => "#16a34a",
          "warning" => "#ca8a04",
          "error" => "#dc2626",
          "gradient_start" => "#6366f1",
          "gradient_end" => "#0891b2"
        }
      },
      "neon-nights" => {
        name: "Neon Nights",
        is_system: true,
        colors: {
          "background" => "#0d0221",
          "surface" => "#150535",
          "surface_alt" => "#1f0a47",
          "primary" => "#ff2d95",
          "secondary" => "#00f0ff",
          "accent" => "#ffcc00",
          "text" => "#f0e6ff",
          "text_muted" => "#8a6bb5",
          "border" => "#2a1058",
          "success" => "#00ff87",
          "warning" => "#ffd700",
          "error" => "#ff3355",
          "gradient_start" => "#ff2d95",
          "gradient_end" => "#00f0ff"
        }
      },
      "sunset-drive" => {
        name: "Sunset Drive",
        is_system: true,
        colors: {
          "background" => "#1a0a1e",
          "surface" => "#2a1020",
          "surface_alt" => "#3a1828",
          "primary" => "#ff6b35",
          "secondary" => "#ffd700",
          "accent" => "#ff1493",
          "text" => "#ffe4d6",
          "text_muted" => "#b08070",
          "border" => "#4a2030",
          "success" => "#00e676",
          "warning" => "#ffab00",
          "error" => "#ff1744",
          "gradient_start" => "#ff6b35",
          "gradient_end" => "#ffd700"
        }
      },
      "ocean-deep" => {
        name: "Ocean Deep",
        is_system: true,
        colors: {
          "background" => "#0a1628",
          "surface" => "#0f2040",
          "surface_alt" => "#152a52",
          "primary" => "#4fc3f7",
          "secondary" => "#81c784",
          "accent" => "#ffb74d",
          "text" => "#e0f0ff",
          "text_muted" => "#6080a0",
          "border" => "#1a3060",
          "success" => "#66bb6a",
          "warning" => "#ffa726",
          "error" => "#e53935",
          "gradient_start" => "#4fc3f7",
          "gradient_end" => "#81c784"
        }
      }
    }

    themes.each_value { |attrs| create!(attrs) }
  end
end
