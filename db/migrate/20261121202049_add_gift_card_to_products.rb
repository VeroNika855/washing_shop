class AddGiftCardToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :gift_card, :boolean
  end
end
