class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :userinfo
  before_action :checkacount


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [profile_attributes: [:username,:ruby,:first_name,:last_name,:nickname,:dob,:sex,:phone,:student_num,:course_id,:teacher_name,:commute,:parent_name,:parent_phone,:parent_address,:department,:position,:leaved_at,:created_at,:updated_at] ])
  end

  def userinfo
    if user_signed_in? then
      @myprofile = Profile.where(user_id: current_user.id, leaved_at: nil, status: nil).order(updated_at: :desc).limit(1).first
    end
  end

  def checkacount
    if user_signed_in? then
      myactivitynow = Attendance.where(user_id: current_user.id, date: Date.current.strftime("%Y-%m-%d"))
      myprofile = Profile.where(user_id: current_user.id, status: nil).order(updated_at: :desc).limit(1).first
      if myprofile.image.file.nil? && !(request.path_info == "/profile/info/#{current_user.id}")
        flash[:alert] = "アカウントが承認されていません"
        redirect_to "/profile/info/#{current_user.id}"
      end
      if myactivitynow.blank? && current_user.role_id.slice(0) == "2" && !(controller_path == 'attendance') && !(myprofile.image.blank?)
        flash.now[:danger] = "活動開始時刻が登録されていません"
      end
      case current_user.role_id.slice(6)
      when "2"
        channel_id = 'C06GBE7A4NM' # チャンネルIDはパラメータから取得
        message = ":bell:*アラート通知：制限ユーザー検知* \n ログイン通知が有効にされたユーザーがログインしました。確認してください。\n>TIME STAMP：#{Time.now}\n><https://action-club.jp/profile/info/#{current_user.id}|ID：#{format("%06d", current_user.id)} >\n>NAME：#{myprofile.username}" # 送信するメッセージもパラメータから取得
        result2 = SlackSendMessageToChannelService.send_message_to_channel(channel_id, message)
      when "3"
        channel_id = 'C06GBE7A4NM' # チャンネルIDはパラメータから取得
        message = ":bell:*アラート通知：制限ユーザー検知* \n ロックされたアカウントがログインを試みました。確認してください。\n>TIME STAMP：#{Time.now}\n><https://action-club.jp/profile/info/#{current_user.id}|ID：#{format("%06d", current_user.id)} >\n>NAME：#{myprofile.username}" # 送信するメッセージもパラメータから取得
        result2 = SlackSendMessageToChannelService.send_message_to_channel(channel_id, message)
        flash[:alert] = "アカウントがロックアウトされています"
        sign_out_and_redirect(current_user)
      end
    end
  end

  if Rails.env.production?
    rescue_from StandardError, with: :render_500
  end
  private

  def render_500(exception)
    logger.error(exception.message)
    logger.error(exception.backtrace.join("\n"))
    render file: Rails.root.join('public/500.html'), status: :internal_server_error,
                                                     layout: false,
                                                     content_type: 'text/html'
  end

end
