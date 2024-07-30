# app/services/create_event_request_service.rb
class CreateEventRequestService < BaseRequestService
  def initialize(current_user, params)
    super(nil) # BaseRequestServiceには引数を渡さない
    @current_user = current_user
    @params = params
  end

  def create_request
    ActiveRecord::Base.transaction do
      request = Request.create!(
        user_id: @current_user.id,
        title: "イベント作成リクエスト",
        status: "info",
        kind: "event_creation",
        event_title: @params[:event_title],
        event_description: @params[:event_description],
        event_start_date_time: @params[:event_start_date_time],
        event_end_date_time: @params[:event_end_date_time],
        event_announcement_date: @params[:event_announcement_date]
      )
      notify_approver(request)
    end
  end

  def approve(request_id)
    ActiveRecord::Base.transaction do
      request = Request.find(request_id)
      approver_username = @current_user.profile.username
      if request.update!(status: "success", approver: approver_username)
        Event.create!(
          title: request.event_title,
          description: request.event_description,
          start_date_time: request.event_start_date_time,
          end_date_time: request.event_end_date_time,
          announcement_date: request.event_announcement_date,
          organizer_id: request.user_id, # 申請者のユーザーID
          display_flag: 1  # デフォルトで1を設定
        )
        send_approval_notification(request) # 承認通知の送信
      end
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
  
      User.where('SUBSTRING(role_id, 1) >= ?', '5').find_each do |user|
        SlackSendMessageToUserService.send_message_to_user(user.id, message)
      end
    rescue => e
      # 例外が発生した場合の処理
      # 例: ログにエラーを記録する
      Rails.logger.error "Failed to send Slack notification in notify_approver: #{e.message}"
    end
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
