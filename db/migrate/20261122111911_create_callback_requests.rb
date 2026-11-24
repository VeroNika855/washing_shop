class CreateCallbackRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :callback_requests do |t|
      t.string :name
      t.string :phone
      t.boolean :processed

      t.timestamps
    end
  end
end
