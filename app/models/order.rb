class Order < ApplicationRecord
  CARD_PAYMENT = "Переказ на картку".freeze
  DELIVERY_METHODS = ["Нова пошта", "Кур'єр", "Самовивіз"].freeze
  PAYMENT_METHODS = ["Оплата при отриманні", CARD_PAYMENT].freeze

  has_many :order_items, dependent: :destroy
  belongs_to :user, optional: true

  enum :status, { new_order: "Нове", confirmed: "Підтверджене",
                  shipped: "Відправлене", done: "Виконане", canceled: "Скасоване" }

  validates :customer_name, :phone, :address, presence: true
  validates :phone, format: { with: /\A\+?[0-9\s\-()]{10,16}\z/, message: :phone_format }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: :email_format }, allow_blank: true
  validates :delivery, inclusion: { in: DELIVERY_METHODS, message: :choose }
  validates :payment, inclusion: { in: PAYMENT_METHODS, message: :choose }
end