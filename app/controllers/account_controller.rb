class AccountController < ApplicationController
  def show
    @orders = current_user ? current_user.orders.includes(order_items: :product).order(created_at: :desc) : []
  end
end