class SessionsController < ApplicationController
  def new
    redirect_to account_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password])
      log_in(user)
      redirect_to account_path, notice: t("flash.logged_in")
    else
      flash.now[:alert] = t("flash.bad_login")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: t("flash.logged_out")
  end
end