class AddConstraintsAndIndexes < ActiveRecord::Migration[7.2]
  def change
    # --- Товари: обов'язкові поля й значення за замовчуванням ---
    change_column_null :products, :name, false, "Без назви"
    change_column_null :products, :manufacturer, false, "Невідомо"
    change_column_null :products, :price, false, 0
    change_column_null :products, :stock, false, 0
    change_column_null :products, :active, false, true
    change_column_default :products, :price, from: nil, to: 0
    change_column_default :products, :stock, from: nil, to: 0
    change_column_default :products, :active, from: nil, to: true

    add_check_constraint :products, "price >= 0", name: "products_price_non_negative"
    add_check_constraint :products, "stock >= 0", name: "products_stock_non_negative"

    # --- Замовлення ---
    change_column_null :orders, :customer_name, false, "—"
    change_column_null :orders, :phone, false, "—"
    change_column_null :orders, :address, false, "—"
    change_column_null :orders, :delivery, false, "—"
    change_column_null :orders, :payment, false, "—"
    change_column_null :orders, :status, false, "Нове"
    change_column_null :orders, :total, false, 0
    change_column_default :orders, :status, from: nil, to: "Нове"
    change_column_default :orders, :total, from: nil, to: 0

    # --- Позиції замовлення ---
    change_column_null :order_items, :quantity, false, 1
    change_column_null :order_items, :unit_price, false, 0
    add_check_constraint :order_items, "quantity > 0", name: "order_items_quantity_positive"

    # --- Унікальність моделі в межах виробника ---
    add_index :products, [:manufacturer, :model_number], unique: true

    # --- Індекси для швидкого пошуку, фільтрів і сортування ---
    add_index :products, :active
    add_index :products, :price
    add_index :products, :load_type
    add_index :products, :energy_class
    add_index :products, :spin_speed
    add_index :orders, :created_at
    add_index :orders, :status
  end
end