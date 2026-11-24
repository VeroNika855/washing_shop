class InfoController < ApplicationController
  SLUGS = %w[about contacts delivery payment warranty returns trade-in].freeze

  def show
    raise ActiveRecord::RecordNotFound unless SLUGS.include?(params[:slug])
    @key = params[:slug].tr("-", "_")
  end
end