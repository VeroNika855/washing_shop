class UsersController < ApplicationController
  def new
    redirect_to account_path and return if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      redirect_to account_path, notice: t("flash.registered")
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error(e.message)
    flash.now[:alert] = t("flash.register_failed")
    render :new, status: :service_unavailable
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end