class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google
    @user = User.find_for_google(request.env['omniauth.auth'])

    if @user
      if @user.persisted?
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'Google')
        logger.debug("[INFO] User Login USER_ID：#{format("%06d", @user.id)} at:#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    else
      flash[:alert] = I18n.t('devise.omniauth_callbacks.failure', kind: 'Google', reason: 'アカウントが見つかりませんでした。')
      redirect_to new_user_session_path
    end
  end
end
