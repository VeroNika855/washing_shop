module Admin
  class OrdersController < BaseController
    def index
      @orders = Order.order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if Order.statuses.key?(params[:status].to_s)
    end

    def show
      @order = Order.includes(order_items: :product).find(params[:id])
    end

    def update
      @order = Order.includes(order_items: :product).find(params[:id])
      new_status = params.dig(:order, :status).to_s

      unless Order.statuses.key?(new_status)
        redirect_to admin_order_path(@order), alert: "Не вдалося змінити статус."
        return
      end

      was_canceled = @order.canceled?
      will_cancel = new_status == "canceled"

      Order.transaction do
        @order.update!(status: new_status)

        if will_cancel && !was_canceled
          # Скасування: повертаємо товари на склад
          @order.order_items.each { |item| item.product.increment!(:stock, item.quantity) }
        elsif was_canceled && !will_cancel
          # Відновлення скасованого замовлення: знову списуємо (перевірка stock >= 0 у моделі)
          @order.order_items.each do |item|
            item.product.update!(stock: item.product.stock - item.quantity)
          end
        end
      end

      notice = if will_cancel && !was_canceled
                 "Статус оновлено. Товари повернуто на склад."
               else
                 "Статус оновлено."
               end
      redirect_to admin_order_path(@order), notice: notice
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_order_path(@order),
                  alert: "Не вдалося змінити статус: на складі недостатньо товару для відновлення замовлення."
    end
  end
end