class CallbackRequest < ApplicationRecord
  has_many :notes, class_name: "CallbackNote", dependent: :destroy

  validates :phone, presence: true,
                    format: { with: /\A\+?[0-9\s\-()]{10,16}\z/, message: :phone_format },
                    allow_blank: true

  # Заявки, на які ще не передзвонили
  scope :pending, -> { where(processed: [false, nil]) }
end