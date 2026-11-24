class CallbackNote < ApplicationRecord
  belongs_to :callback_request

  validates :body, presence: true, length: { maximum: 1000 }
end