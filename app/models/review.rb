class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :rating, inclusion: { in: 1..5 }
  validates :body, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id }

  # Зберігаємо підсумки в товарі, щоб каталог не робив зайвих запитів
  after_commit :refresh_product_stats

  private

  def refresh_product_stats
    product.update_columns(reviews_count: product.reviews.count,
                           rating_sum: product.reviews.sum(:rating))
  end
end