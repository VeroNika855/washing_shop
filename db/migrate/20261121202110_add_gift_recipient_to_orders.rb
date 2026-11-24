class AddGiftRecipientToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :gift_recipient_name, :string
    add_column :orders, :gift_recipient_phone, :string
  end
end
