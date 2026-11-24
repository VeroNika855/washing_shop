module AdsHelper
  FREE_SHIPPING_FROM = 10_000

  # Сума кошика з урахуванням акцій
  def cart_total_now
    (session[:cart] || {}).sum do |id, qty|
      product = Product.find_by(id: id)
      product ? product.current_price.to_i * qty.to_i : 0
    end
  end
end