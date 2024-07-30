# app/services/update_profile_request_service.rb
class UpdateProfileRequestService < BaseRequestService
  def initialize(user, profile_params)
    @user = user
    @profile_params = profile_params
    super(nil) # BaseRequestServiceの初期化
  end

  def create_request
    ActiveRecord::Base.transaction do
      # 既存のプロフィールから写真を取得
      existing_image = Profile.find_by(user_id: @user.id, status: nil).try(:image)

      # 新しいプロフィールレコードの作成
      new_profile = Profile.new(@profile_params)

      # 写真データを設定
      new_profile.image = existing_image if existing_image

      # 新しいプロフィールレコードを保存
      new_profile.save!

      # リクエストレコードの作成
      @request = Request.create!(user_id: @user.id, title: "個人情報変更リクエスト", kind: "hr_UserUpdate", target: new_profile.user_id)
      notify_approver(@request)
    end
  end

  def approve(request)
    @request = request
    ActiveRecord::Base.transaction do
      username = @user.profile.username
      update_request_status("success", username)
      old_profile = Profile.where(user_id: @request.target, status: nil).order(id: :desc).first
      old_profile.update!(status: 'no') if old_profile.present?
      new_profile = Profile.where(user_id: @request.target, status: 'no').order(id: :desc).first
      new_profile.update!(status: nil) if new_profile.present?
      send_approval_notification(@request)
    end
  end

  def deny(request)
    @request = request
    ActiveRecord::Base.transaction do
      username = @user.profile.username
      update_request_status("danger", username)
      new_profile = Profile.where(user_id: @request.target, status: 'no').order(id: :desc).first
      new_profile.update!(status: 'deny') if new_profile.present?
      send_denial_notification(@request)
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

  def send_approval_notification(request)
    message = ":white_check_mark:*申請が承認されました* \n 内容を確認してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)}>\n>WF名：#{request.title} \n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>処理日時：#{Time.now.strftime('%Y-%m-%d %H:%M')} \n>WF処理者：#{request.approver}"
    SlackSendMessageToUserService.send_message_to_user(request.user_id, message)
  end

  def send_denial_notification(request)
    message = ":negative_squared_cross_mark:*申請が否認されました* \n 内容を確認して必要であれば再申請してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)} >\n>WF名：#{request.title}\n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>処理日時：#{Time.now.strftime('%Y-%m-%d %H:%M')} \n>WF処理者：#{request.approver}"
    SlackSendMessageToUserService.send_message_to_user(request.user_id, message)
  end
end
