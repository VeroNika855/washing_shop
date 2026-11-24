class CartController < ApplicationController
  def show
    @items = cart_items
    @total = @items.sum { |item| item[:product].current_price * item[:quantity] }
  end

  def add
    product = Product.active.find(params[:product_id])

    if product.stock.to_i <= 0
      redirect_back fallback_location: products_path, alert: t("flash.out_of_stock")
      return
    end

    session[:cart] ||= {}
    id = product.id.to_s
    session[:cart][id] = [session[:cart][id].to_i + 1, product.stock].min

    redirect_back fallback_location: cart_path, notice: t("flash.cart_added")
  end

  def update_item
    product = Product.active.find(params[:product_id])
    id = product.id.to_s

    if session[:cart]&.key?(id)
      session[:cart][id] = params[:quantity].to_i.clamp(1, product.gift_card? ? 10 : [product.stock.to_i, 1].max)
    end

    redirect_to cart_path
  end

  def remove
    session[:cart]&.delete(params[:product_id].to_s)
    redirect_to cart_path, notice: t("flash.cart_removed")
  end
end