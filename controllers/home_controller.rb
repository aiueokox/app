class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:helthcheck]
  
  def helthcheck
    render plain: 'OK'
  end
  def index
    @myRequests = Request.where(user_id: current_user.id).order(updated_at: :desc).limit(5)
    if current_user.role_id.slice(0) == "4"
      @Requests = Request.order(updated_at: :desc).limit(5)
    elsif current_user.role_id.slice(2) >= "5"
      @Requests = Request.where("kind NOT LIKE '%cf%' AND kind NOT LIKE '%gd%'").order(updated_at: :desc).limit(5)
    elsif current_user.role_id.slice(3) >= "3" && current_user.role_id.slice(4) == "1"
      @Requests = Request.where("kind NOT LIKE '%hr%'").order(updated_at: :desc).limit(5)
    elsif current_user.role_id.slice(3) >= "3"
      @Requests = Request.where("kind NOT LIKE '%hr%' AND kind NOT LIKE '%gd%'").order(updated_at: :desc).limit(5)
    elsif current_user.role_id.slice(4) == "1"
      @Requests = Request.where("kind NOT LIKE '%hr%' AND kind NOT LIKE '%cf%'").order(updated_at: :desc).limit(5)
    elsif current_user.role_id.slice(1) >= "5"
      @Requests = Request.where("kind NOT LIKE '%hr%' AND kind NOT LIKE '%cf%' AND kind NOT LIKE '%gd%'").order(updated_at: :desc).limit(5)
    end
    @Activities = Attendance.where(out: nil, date: Date.current.strftime("%Y-%m-%d"))
    @president = Profile.where(leaved_at: nil, status: nil, department_id: "40").order(id: :desc).first
    @borrow_key = WebLog.where(event_name: "borrow_key").where("created_at >= ?", Date.today).order(id: :desc).first

    @events = Event.joins(:event_participants)
                   .where(event_participants: { user_id: current_user.id })
                   .where('start_date_time >= ? AND end_date_time >= ?', Time.now - 1.hour, Time.now)
                   .where('display_flag = 1')
                   .limit(1)

  end
  def recruit
    
  end
  def logs
    if current_user.role_id.slice(0) == "4"
      else
        flash[:alert] = "権限がありません"
        redirect_to root_path
      end
  end
  def resourceMonitor
    if current_user.role_id.slice(0) == "4"
      else
        flash[:alert] = "権限がありません"
        redirect_to root_path
      end
  end
  def commingsoon
    flash[:alert] = "【 404 Page Not Found 】ページが存在しません。管理者へお問合せください。"
    redirect_to root_path
  end
  def test_slack
    user_id = current_user.id # ユーザーIDはパラメータから取得
    message = "test-to-user from #{current_user.profile.username}（#{format("%06d", current_user.id)}）" # 送信するメッセージもパラメータから取得

    result1 = SlackSendMessageToUserService.send_message_to_user(user_id, message)

    channel_id = 'C06GBE7A4NM' # チャンネルIDはパラメータから取得
    message = "test-to-channel from #{current_user.profile.username}（#{format("%06d", current_user.id)}）" # 送信するメッセージもパラメータから取得

    result2 = SlackSendMessageToChannelService.send_message_to_channel(channel_id, message)

    if result1 && result2
      flash[:notice] = 'Slackへの送信に成功しました'
    else
      flash[:alert] = 'Slackへの送信に失敗しました'
    end
    redirect_to root_path
  end
end
