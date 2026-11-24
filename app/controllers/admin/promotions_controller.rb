module Admin
  class PromotionsController < BaseController
    def index
      @products = Product.order(:manufacturer, :name)
      @promos = Promotion.where.not(product_id: nil).index_by(&:product_id)
    end

    # Створити або оновити акцію на товар
    def save
      product = Product.find(params[:product_id])
      percent = params[:discount_percent].to_i
      amount = params[:duration].to_i
      unit = %w[hours days].include?(params[:unit]) ? params[:unit] : "days"
      starts_at = Time.zone.parse(params[:starts_at].to_s)

      unless percent.between?(1, 90)
        redirect_to admin_promotions_path, alert: "Знижка має бути від 1 до 90%."
        return
      end
      if starts_at.nil? || amount < 1
        redirect_to admin_promotions_path, alert: "Вкажіть коректні дату початку й тривалість."
        return
      end

      promo = Promotion.find_or_initialize_by(product_id: product.id)
      promo.assign_attributes(
        title: "Знижка -#{percent}% на #{product.name}",
        kind: "Знижки",
        discount_percent: percent,
        description: "Акційна ціна на #{product.name}.",
        conditions: "Знижка діє у вказаний період і застосовується автоматично в кошику.",
        starts_at: starts_at,
        ends_at: starts_at + amount.public_send(unit),
        active: true
      )

      if promo.save
        promo.products = [product]
        redirect_to admin_promotions_path, notice: "Акцію для «#{product.name}» збережено."
      else
        redirect_to admin_promotions_path, alert: promo.errors.full_messages.to_sentence
      end
    end

    # Зняти акцію з товару
    def stop
      Promotion.where(product_id: params[:product_id]).destroy_all
      redirect_to admin_promotions_path, notice: "Акцію знято."
    end
  end
end