# app/services/update_attendance_request_service.rb
class UpdateAttendanceRequestService < BaseRequestService
  def initialize(current_user, params)
    super(nil) # BaseRequestServiceには引数を渡さない
    @current_user = current_user
    @params = params
  end

  def create_request
    ActiveRecord::Base.transaction do
      now_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      req_time = "#{now_time.slice(0..9)} #{@params[:time]}:00 +0900"
      request = Request.create!(
        user_id: @current_user.id,
        title: "打刻時刻修正リクエスト",
        kind: "hr_ModifyUpdate",
        value: req_time
      )
      notify_approver(request)
    end
  end

  def approve(request_id)
    ActiveRecord::Base.transaction do
      request = Request.find(request_id)
      approver_username = @current_user.profile.username
      request.update!(status: "success", approver: approver_username)
      update_attendance(request)
    end
  end

  def deny(request_id)
    ActiveRecord::Base.transaction do
      request = Request.find(request_id)
      approver_username = @current_user.profile.username
      request.update!(status: "danger", approver: approver_username)
      send_denial_notification(request)
    end
  end

  private

  def notify_approver(request)
    begin
      request_username = User.joins(:profile).find_by(id: request.user_id).profile.username
      message = ":page_with_curl:*WF作成通知* \n 内容を確認して対応してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)} >\n>WF名：#{request.title} \n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>WF作成者：<https://action-club.jp/profile/info/#{request.user_id}|#{request_username}（#{format("%06d", request.user_id)}）>"
  
        SlackSendMessageToChannelService.send_message_to_channel('C021TKWFE4E', message)

    rescue => e
      # 例外が発生した場合の処理
      # 例: ログにエラーを記録する
      Rails.logger.error "Failed to send Slack notification in notify_approver: #{e.message}"
    end

  end

  def update_attendance(request)
    user_attendance = Attendance.order(id: :desc).find_by(user_id: request.user_id)
    req_time = request.value

    if user_attendance.nil? || user_attendance.date.to_s != Date.current.strftime("%Y-%m-%d")
      Attendance.create(
        user_id: request.user_id, 
        in: req_time, 
        date: req_time.slice(0..9), 
        updater: "システム（打刻修正申請）"
      )
    else
      user_attendance.update(out: req_time, updater: "システム（打刻修正申請）")
    end

    send_approval_notification(request)
  end

  def send_approval_notification(request)
    message = ":white_check_mark:*申請が承認されました* \n 内容を確認してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)}>\n>WF名：#{request.title} \n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>処理日時：#{Time.now.strftime('%Y-%m-%d %H:%M')} \n>WF処理者：#{request.approver}"
    SlackSendMessageToUserService.send_message_to_user(request.user_id, message)

  end

  def send_denial_notification(request)
    message = ":negative_squared_cross_mark:*申請が否認されました* \n 内容を確認して必要であれば再申請してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)} >\n>WF名：#{request.title}\n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>処理日時：#{Time.now.strftime('%Y-%m-%d %H:%M')} \n>WF処理者：#{request.approver}"
    SlackSendMessageToUserService.send_message_to_user(request.user_id, message)
  end
end
