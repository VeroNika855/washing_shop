module Admin
  class DashboardController < BaseController
    def index
      cancelled = Order.statuses.select { |_, label| label.to_s.match?(/Скас/) }.keys
      valid = Order.where.not(status: cancelled)

      week_start = 6.days.ago.beginning_of_day
      week_orders = valid.where(created_at: week_start..).includes(:order_items).to_a

      @revenue_total = valid.includes(:order_items).sum { |order| order.total.to_i }
      @revenue_week  = week_orders.sum { |order| order.total.to_i }
      @orders_week   = week_orders.size
      @orders_today  = valid.where(created_at: Time.current.beginning_of_day..).count
      @pending_calls = CallbackRequest.pending.count

      # Графік виручки за 7 днів
      by_day = week_orders.group_by { |order| order.created_at.to_date }
      @chart = (0..6).map do |i|
        day = Date.current - (6 - i)
        [day, (by_day[day] || []).sum { |order| order.total.to_i }]
      end
      @chart_max = [@chart.map(&:last).max, 1].max

      # Топ-5 товарів за кількістю проданих одиниць
      top = OrderItem.where(order_id: valid.select(:id))
                     .group(:product_id)
                     .order(Arel.sql("SUM(order_items.quantity) DESC"))
                     .limit(5)
                     .sum(:quantity)
      products = Product.where(id: top.keys).index_by(&:id)
      @top_products = top.filter_map { |id, qty| [products[id], qty] if products[id] }

      @low_stock = Product.catalog.where("stock <= 3").order(:stock).limit(5)
      @recent_orders = Order.includes(:order_items).order(created_at: :desc).limit(5)
    end
  end
end