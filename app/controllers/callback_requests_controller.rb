class CallbackRequestsController < ApplicationController
  def create
    callback = CallbackRequest.new(callback_params)
    if callback.save
      redirect_back fallback_location: root_path, notice: t("flash.callback_sent")
    else
      redirect_back fallback_location: root_path, alert: callback.errors.full_messages.to_sentence
    end
  end

  private

  def callback_params
    params.require(:callback_request).permit(:name, :phone)
  end
end