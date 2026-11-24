module FavoriteHelper
  # Список id обраних товарів поточного користувача (запит робиться один раз на сторінку)
  def favorite_ids
    @favorite_ids ||= logged_in? ? Favorite.where(user_id: current_user.id).pluck(:product_id) : []
  end
end