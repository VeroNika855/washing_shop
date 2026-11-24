class PagesController < ApplicationController
  SLUGS = %w[akcii podarunkovi-kartky dostavka povernennia trade-in dopomoha].freeze
  DEMO = %w[akcii podarunkovi-kartky trade-in].freeze

  def show
    return render_not_found unless SLUGS.include?(params[:slug])

    @key = params[:slug].tr("-", "_")
    @demo = DEMO.include?(params[:slug])
  end
end