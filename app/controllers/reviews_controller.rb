class ReviewsController < ApplicationController
  before_action :require_login_for_reviews

  def create
    product = Product.catalog.find(params[:product_id])
    review = product.reviews.find_or_initialize_by(user_id: current_user.id)
    review.assign_attributes(params.require(:review).permit(:rating, :body))

    if review.save
      redirect_to product_path(product, anchor: "reviews"), notice: t("reviews.saved")
    else
      redirect_to product_path(product, anchor: "reviews"), alert: t("reviews.invalid")
    end
  end

  def destroy
    review = Review.find(params[:id])

    if admin? || review.user_id == current_user.id
      review.destroy
      redirect_to product_path(review.product_id, anchor: "reviews"), notice: t("reviews.deleted")
    else
      redirect_to root_path, alert: t("flash.forbidden")
    end
  end

  private

  def require_login_for_reviews
    redirect_to login_path, alert: t("reviews.login_required") unless logged_in?
  end
end