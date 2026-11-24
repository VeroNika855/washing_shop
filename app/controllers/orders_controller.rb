class OrdersController < ApplicationController
  before_action :require_cart, only: %i[new create]
  helper_method :gift_in_cart?

  def new
    @order = Order.new(customer_name: current_user&.name, email: current_user&.email)
    load_summary
  end

  def create
    load_summary
    @order = Order.new(order_params)
    @order.status = :new_order
    @order.total = @total
    @order.user = current_user

    # Повторна перевірка наявності (Use Case 3.2.4, крок 4)
    if @items.any? { |item| item[:quantity] > item[:product].stock.to_i }
      redirect_to cart_path, alert: t("flash.qty_changed")
      return
    end

    # Для подарункового сертифіката потрібні дані одержувача
    if gift_in_cart? && (@order.gift_recipient_name.blank? || @order.gift_recipient_phone.blank?)
      @order.valid?
      @order.errors.add(:base, t("flash.gift_recipient_required"))
      render :new, status: :unprocessable_entity
      return
    end

    # Оплата карткою: перевіряємо дані (імітація платежу, дані не зберігаються)
    paid_by_card = @order.payment == Order::CARD_PAYMENT
    if paid_by_card
      problems = card_errors
      if problems.any?
        @order.valid?
        problems.each { |msg| @order.errors.add(:base, msg) }
        render :new, status: :unprocessable_entity
        return
      end
    end

    Order.transaction do
      @order.save!
      @items.each do |item|
        product = item[:product]
        @order.order_items.create!(product: product, quantity: item[:quantity], unit_price: product.current_price)
        product.update!(stock: product.stock - item[:quantity])
      end
    end

    session[:order_ids] = (session[:order_ids] || []) + [@order.id]
    session[:cart] = {}
    redirect_to order_path(@order), notice: (t("cardpay.paid") if paid_by_card)
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error(e.message)
    redirect_to cart_path, alert: t("flash.order_failed")
  end

  def show
    @order = Order.find_by(id: params[:id])
    own = @order && ((session[:order_ids] || []).include?(@order.id) ||
                     (logged_in? && @order.user_id == current_user.id))
    redirect_to root_path, alert: t("flash.order_not_found") unless own
  end

  private

  def require_cart
    redirect_to cart_path, alert: t("flash.cart_empty") if cart_items.empty?
  end

  def load_summary
    @items = cart_items
    @total = @items.sum { |item| item[:product].current_price * item[:quantity] }
  end

  def gift_in_cart?
    cart_items.any? { |item| item[:product].gift_card? }
  end

  def order_params
    params.require(:order).permit(:customer_name, :phone, :email, :address, :delivery, :payment,
                                  :gift_recipient_name, :gift_recipient_phone)
  end

  # ---- Перевірка картки ----
  def card_errors
    card = params[:card] || {}
    number = card[:number].to_s.gsub(/\s/, "")
    errors = []
    errors << t("cardpay.err_number") unless number.match?(/\A\d{16}\z/) && luhn_valid?(number)
    errors << t("cardpay.err_expiry") unless card_expiry_ok?(card[:expiry].to_s)
    errors << t("cardpay.err_cvv") unless card[:cvv].to_s.match?(/\A\d{3}\z/)
    errors << t("cardpay.err_holder") if card[:holder].to_s.strip.length < 3
    errors
  end

  def luhn_valid?(number)
    sum = number.reverse.chars.each_with_index.sum do |ch, i|
      d = ch.to_i
      d *= 2 if i.odd?
      d -= 9 if d > 9
      d
    end
    (sum % 10).zero?
  end

  def card_expiry_ok?(value)
    match = value.match(%r{\A(\d{2})/(\d{2})\z}) or return false
    month = match[1].to_i
    return false unless (1..12).cover?(month)

    Date.new(2000 + match[2].to_i, month, -1) >= Date.current
  end
end