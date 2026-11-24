class CreatePromotions < ActiveRecord::Migration[7.2]
  def change
    create_table :promotions do |t|
      t.string :title
      t.string :kind
      t.text :description
      t.text :conditions
      t.string :image_url
      t.integer :discount_percent
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active

      t.timestamps
    end
  end
end
