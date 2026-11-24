class GiftCardsController < ApplicationController
  NOMINALS = [100, 200, 500, 1000, 2000, 3000, 5000, 10_000, 20_000].freeze
  MAX_PER_NOMINAL = 10

  def show
    @nominals = NOMINALS
    @selected = NOMINALS.include?(params[:nominal].to_i) ? params[:nominal].to_i : 1000
  end

  def create
    nominal = params[:nominal].to_i
    unless NOMINALS.include?(nominal)
      redirect_to gift_cards_path, alert: t("flash.gift_invalid")
      return
    end

    # Товар-сертифікат створюється при першій покупці цього номіналу
    product = Product.find_or_create_by!(model_number: "GIFT-#{nominal}") do |p|
      p.name = "Електронний подарунковий сертифікат #{nominal} грн"
      p.manufacturer = "Інтернет-магазин"
      p.description = "Електронний подарунковий сертифікат номіналом #{nominal} грн."
      p.gift_card = true
      p.price = nominal
      p.stock = 100_000
      p.active = true
    end

    # Той самий номінал: збільшуємо кількість. Інший номінал: окрема позиція.
    session[:cart] ||= {}
    id = product.id.to_s
    session[:cart][id] = [session[:cart][id].to_i + 1, MAX_PER_NOMINAL].min

    redirect_to cart_path, notice: t("flash.cart_added")
  end
end