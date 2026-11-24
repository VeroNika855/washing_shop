class ProductsController < ApplicationController
  PER_PAGE = 52 # 4 в ширину × 13 рядів

  def index
    @manufacturers = Product.catalog.distinct.order(:manufacturer).pluck(:manufacturer)

    @products = Product.catalog
                       .search(params[:q])
                       .by_manufacturer(params[:manufacturer])
                       .by_load_type(params[:load_type])
                       .by_energy_class(params[:energy_class])
                       .min_spin_speed(params[:spin_speed])
                       .price_between(params[:min_price], params[:max_price])
                       .order_by_price(params[:sort])

    @total = @products.count
    @pages = [(@total / PER_PAGE.to_f).ceil, 1].max
    @page = params[:page].to_i.clamp(1, @pages)

    # "Показати більше": показуємо всі сторінки від першої до поточної
    if params[:more] == "1"
      @products = @products.limit(@page * PER_PAGE)
    else
      @products = @products.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    end

    @brand_counts = Product.catalog.group(:manufacturer).order(:manufacturer).count
    @load_counts = Product.catalog.where.not(load_type: [nil, ""]).group(:load_type).count
  end

  def show
    @product = Product.active.find(params[:id])

    # Схожі: той самий тип завантаження, найближча ціна
    @similar = Product.catalog
                      .where.not(id: @product.id)
                      .where(load_type: @product.load_type)
                      .order(Arel.sql("ABS(price - #{@product.price.to_i})"))
                      .limit(4)

    # Нещодавно переглянуті: запам'ятовуємо в сесії останні 10
    ids = ([@product.id] + Array(session[:recent])).uniq.first(10)
    session[:recent] = ids
    @recent = Product.active.where(id: ids - [@product.id]).sort_by { |p| ids.index(p.id) }.first(4)

    # Відгуки
    @reviews = @product.reviews.includes(:user).order(created_at: :desc).limit(30).to_a
    @rating_counts = @product.reviews.group(:rating).count
    @my_review = current_user && @product.reviews.find_by(user_id: current_user.id)
    # Хто з авторів справді купував цей товар
    @verified_ids = Order.where(user_id: @reviews.map(&:user_id))
                         .joins(:order_items).where(order_items: { product_id: @product.id })
                         .distinct.pluck(:user_id)
  end
end