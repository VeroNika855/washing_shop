class CartQuickController < ApplicationController
  def create
    product = Product.active.find(params[:product_id])

    if product.stock.to_i <= 0
      render json: { error: t("cart_quick.out_of_stock"), count: cart_count }, status: :unprocessable_entity
      return
    end

    session[:cart] ||= {}
    id = product.id.to_s
    session[:cart][id] = [session[:cart][id].to_i + 1, product.stock].min

    render json: { message: t("cart_quick.added"), count: cart_count }
  end
end