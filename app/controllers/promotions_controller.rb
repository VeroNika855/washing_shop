class PromotionsController < ApplicationController
  def index
    @kind_counts = Promotion.running.group(:kind).count
    @promotions = Promotion.running.by_kind(params[:kind])
    @promotions = if params[:sort] == "ending"
                    @promotions.order(:ends_at)
                  else
                    @promotions.order(starts_at: :desc)
                  end
  end

  def show
    @promotion = Promotion.visible.find(params[:id])
    @products = @promotion.products.active
  end
end