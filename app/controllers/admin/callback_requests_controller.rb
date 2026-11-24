module Admin
  class CallbackRequestsController < BaseController
    def index
      # Нові заявки зверху, опрацьовані внизу
      @requests = CallbackRequest.includes(:notes).order(:processed, created_at: :desc)
    end

    def toggle
      request_record = CallbackRequest.find(params[:id])
      request_record.update!(processed: !request_record.processed)
      redirect_to admin_callback_requests_path
    end

    def destroy
      CallbackRequest.find(params[:id]).destroy
      redirect_to admin_callback_requests_path, notice: "Заявку видалено."
    end
  end
end