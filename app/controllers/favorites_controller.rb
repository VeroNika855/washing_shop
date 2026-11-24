class FavoritesController < ApplicationController
  def index
    unless logged_in?
      redirect_to login_path, alert: t("favorites.login_required")
      return
    end

    ids = Favorite.where(user_id: current_user.id).order(created_at: :desc).pluck(:product_id)
    @products = Product.catalog.where(id: ids).sort_by { |p| ids.index(p.id) }
  end

  def toggle
    unless logged_in?
      if wants_json?
        render json: { login_url: login_path }, status: :unauthorized
      else
        redirect_to login_path, alert: t("favorites.login_required")
      end
      return
    end

    product = Product.catalog.find(params[:product_id])
    favorite = Favorite.find_by(user_id: current_user.id, product_id: product.id)

    if favorite
      favorite.destroy
      liked = false
    else
      Favorite.create(user_id: current_user.id, product_id: product.id)
      liked = true
    end

    if wants_json?
      render json: { liked: liked, count: Favorite.where(user_id: current_user.id).count }
    else
      redirect_back fallback_location: favorites_path, status: :see_other
    end
  end

  private

  def wants_json?
    request.headers["Accept"].to_s.include?("application/json")
  end
end