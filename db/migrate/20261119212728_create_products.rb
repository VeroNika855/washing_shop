class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :manufacturer
      t.string :model_number
      t.text :description
      t.decimal :price
      t.integer :stock
      t.string :load_type
      t.decimal :capacity
      t.integer :spin_speed
      t.string :energy_class
      t.boolean :active

      t.timestamps
    end
  end
end
