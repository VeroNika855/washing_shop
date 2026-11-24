class User < ApplicationRecord
  has_secure_password validations: false
  has_many :orders, dependent: :nullify

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: :email_format },
                    allow_blank: true
  validates :password, presence: true,
                       length: { minimum: 6, message: :password_too_short },
                       confirmation: { message: :password_mismatch },
                       if: -> { new_record? || password.present? }

  # Користувач є адміністратором, якщо його пошта є в таблиці admins
  def admin?
    AdminAccount.exists?(email: email)
  end
end