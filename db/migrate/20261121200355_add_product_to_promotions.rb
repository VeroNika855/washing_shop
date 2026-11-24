class AddProductToPromotions < ActiveRecord::Migration[7.2]
  def change
    add_reference :promotions, :product, foreign_key: true, null: true
  end
end