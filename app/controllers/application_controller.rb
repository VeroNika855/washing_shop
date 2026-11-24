class ApplicationController < ActionController::Base

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::ConnectionNotEstablished, ActiveRecord::ConnectionTimeoutError,
              ActiveRecord::StatementInvalid, with: :render_unavailable

  before_action :set_locale

  helper_method :cart_count, :current_user, :logged_in?, :admin?
  
  private

  def set_locale
    session[:locale] = params[:locale] if %w[uk en].include?(params[:locale])
    I18n.locale = session[:locale] || :uk
  end

    def render_not_found
    render "errors/not_found", status: :not_found
  end

  def render_unavailable(error)
    Rails.logger.error("#{error.class}: #{error.message}")
    render "errors/unavailable", status: :service_unavailable, layout: false
  end

  def cart_count
    (session[:cart] || {}).values.sum
  end

  def cart_items
    (session[:cart] || {}).filter_map do |id, qty|
      product = Product.active.find_by(id: id)
      { product: product, quantity: qty } if product
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

    def admin?
    logged_in? && current_user.admin?
  end

  # Використовуватимемо в адмінських контролерах: before_action :require_admin
  def require_admin
        redirect_to root_path, alert: t("flash.forbidden") unless admin?
  end

  # Вхід: оновлюємо сесію (захист від session fixation), але зберігаємо кошик
  def log_in(user)
    keep = session.to_h.slice("cart", "order_ids", "locale")
    reset_session
    keep.each { |k, v| session[k] = v }
    session[:user_id] = user.id
  end
end