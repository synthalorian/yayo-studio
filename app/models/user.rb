class User < ApplicationRecord
  has_secure_password

  has_many :projects, dependent: :destroy

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 255 }
  validates :password, length: { minimum: 8, if: -> { password.present? } }

  def self.default_theme
    "synthwave-84"
  end
end
