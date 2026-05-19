class AiIntegration < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
  validates :provider, presence: true

  scope :enabled, -> { where(enabled: true) }

  PROVIDERS = %w[hermes openai anthropic openrouter local custom].freeze

  validates :provider, inclusion: { in: PROVIDERS }
end
