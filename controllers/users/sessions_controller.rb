# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :authenticate_user!, except: [:new_by_id]
  # before_action :configure_sign_in_params, only: [:create]

  def new_by_id
    if current_user
      redirect_to root_path
    end
  end

  def sign_in_by_id
    user = User.find_by(email: params[:email])
    if user.nil?
      flash[:danger] = "ユーザーが存在しません"
      redirect_to new_user_session_path
    elsif user.role_id.slice(0) == "2"
      # メールアドレスログインに試みたことと、IPアドレスをWebLogに記録
      WebLog.create(user_id: user.id, event_name: "user_login_by_email_tried", value1: request.remote_ip)
      flash[:danger] = "メールアドレスログインの権限がありません"
      redirect_to root_path
    elsif user.valid_password?(params[:password])
      # メールアドレスログインしたことと、IPアドレスをWebLogに記録
      WebLog.create(user_id: user.id, event_name: "user_login_by_email_succeeded", value1: request.remote_ip)
      sign_in user
      redirect_to root_path
    else
      # メールアドレスログインに失敗したことと、IPアドレスをWebLogに記録
      WebLog.create(user_id: user.id, event_name: "user_login_by_email_failed", value1: request.remote_ip)
      flash[:danger] = "パスワードが違います"
      redirect_to request.referrer
    end
  end

  # # GET /resource/sign_in
  # def new

  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
