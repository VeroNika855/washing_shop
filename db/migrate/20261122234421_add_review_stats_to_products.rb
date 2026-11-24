class AddReviewStatsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :reviews_count, :integer
    add_column :products, :rating_sum, :integer
  end
end
