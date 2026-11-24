module Admin
  class CallbackNotesController < BaseController
    def create
      callback = CallbackRequest.find(params[:callback_request_id])
      note = callback.notes.build(body: params.dig(:callback_note, :body).to_s.strip)

      if note.save
        redirect_to admin_callback_requests_path(open: callback.id), notice: "Нотатку додано."
      else
        redirect_to admin_callback_requests_path(open: callback.id),
                    alert: "Нотатка не може бути порожньою або довшою за 1000 символів."
      end
    end

    def destroy
      callback = CallbackRequest.find(params[:callback_request_id])
      callback.notes.find(params[:id]).destroy
      redirect_to admin_callback_requests_path(open: callback.id), notice: "Нотатку видалено."
    end
  end
end