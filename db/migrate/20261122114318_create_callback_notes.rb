class CreateCallbackNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :callback_notes do |t|
      t.references :callback_request, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
