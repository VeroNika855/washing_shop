class AdminAccount < ApplicationRecord
  self.table_name = "admins"

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true
end