class AttendanceController < ApplicationController

  def reqModify

  end

  def reqModifyUpdate
    update_service = UpdateAttendanceRequestService.new(current_user, params)
    update_service.create_request
    redirect_to "/attendance/log"
  end

  def reqDeny
    unless current_user.role_id.slice(2) >= "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    request_id = params[:id]
    update_service = UpdateAttendanceRequestService.new(current_user, params)
    update_service.deny(request_id)
    redirect_to "/request/list"
  end

  def reqDo
    unless current_user.role_id.slice(2) >= "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    request_id = params[:id]
    update_service = UpdateAttendanceRequestService.new(current_user, params)
    update_service.approve(request_id)
    redirect_to "/request/list"
  end

  # def reqModifyUpdate
  #   nowTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  #   reqTime = "#{nowTime.slice!(0..9)} #{params[:time]}:00 +0900"
  #   Request.create(user_id: current_user.id,title: "打刻時刻修正リクエスト",kind: "hr_ModifyUpdate",value: reqTime)
  #   @reqTarget = Request.where(user_id: current_user.id,title: "打刻時刻修正リクエスト",kind: "hr_ModifyUpdate",value: reqTime).order(id: :desc).limit(1).first
  #   wfRole = Profile.joins(:user).select("profiles.*, users.role_id").where(status: nil,leaved_at: nil,).and(User.where("SUBSTRING(role_id, 3, 1) >= '5'")).and(User.where("role_id LIKE ?", "2%"))
  #   wfRole.each do |wfUser|
  #   view_context.slack_send_messege_email("#{wfUser.student_num.downcase}@g.neec.ac.jp",":page_with_curl:*WF作成通知* \n 内容を確認して対応してください。\n>申請No：<https://action-club.jp/request/info/#{@reqTarget.id}|#{format("%05d", @reqTarget.id)} >\n>WF名：#{@reqTarget.title} >\n>申請日時：#{@reqTarget.created_at}\n>WF作成者：<https://action-club.jp/profile/info/#{current_user.id}|#{@myprofile.username}（#{format("%06d", current_user.id)}）>")
  #   end
  #   redirect_to "/attendance/log"
  # end

  # def reqDo
  #   @reqTarget = Request.find(params[:id])
  #   @reqTarget.update(status: "success",approver: @myprofile.username)
  #   user = Attendance.order("id DESC").find_by(user_id: @reqTarget.user_id)
  #   nowTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  #   reqTime = @reqTarget.value
  #   if user.nil? || user.date.to_s != Date.current.strftime("%Y-%m-%d")
  #     Attendance.create({user_id: @reqTarget.user_id, in: reqTime, date: reqTime.slice!(0..9), updater: "システム（打刻修正申請）"})
  #     view_context.slack_send_messege_email("#{view_context.getProfileByUserID(@reqTarget.user_id).student_num.downcase}@g.neec.ac.jp",":white_check_mark:*申請が承認されました* \n 内容を確認してください。\n><https://action-club.jp/request/info/#{@reqTarget.id}|申請No：#{format("%05d", @reqTarget.id)}>\n>WF名：#{@reqTarget.title} \n>申請日時：#{@reqTarget.created_at}\n>処理日時：#{Time.now} >\n>WF処理者：#{@myprofile.username}")
  #     redirect_to "/request/list"
  #   else  
  #     user.update(out: reqTime, updater: "システム（打刻修正申請）")
  #     view_context.slack_send_messege_email("#{view_context.getProfileByUserID(@reqTarget.user_id).student_num.downcase}@g.neec.ac.jp",":white_check_mark:*申請が承認されました* \n 内容を確認してください。\n><https://action-club.jp/request/info/#{@reqTarget.id}|申請No：#{format("%05d", @reqTarget.id)}>\n>WF名：#{@reqTarget.title} \n>申請日時：#{@reqTarget.created_at}\n>処理日時：#{Time.now} >\n>WF処理者：#{@myprofile.username}")
  #     redirect_to "/request/list"
  #   end
  # end

  def list
    @profiles = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil,leaved_at: nil)
    @Activities = Attendance.where(out: nil, date: Date.current.strftime("%Y-%m-%d")).order(created_at: :desc)
    @time = Time.now
  end

  def log
    @profiles = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
    @Activities = Attendance.order(created_at: :desc)
  end

  def success
    if current_user.role_id.slice(0) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    user = Attendance.order("id DESC").find_by(user_id: params[:user_id])
    staff = Profile.find_by(user_id: params[:user_id] ,status: nil ,leaved_at: nil)
    nowTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if staff.nil?
        flash[:alert] = "無効なスタッフです"
        redirect_to attendance_error_path
    else
      if user.nil? || user.date.to_s != Date.current.strftime("%Y-%m-%d")
        Attendance.create({user_id: params[:user_id], in: nowTime, date: nowTime.slice!(0..9), updater: @myprofile.username})
        #ここから、移行期間同期用
        # linkUserId = params[:user_id]
        # redirect_to "/attendance/success_in/#{linkUserId}"
        #ここまで、移行期間同期用
        redirect_to attendance_success_in_path
      else  
        user.update(out: nowTime, updater: @myprofile.username)
        # #ここから、移行期間同期用
        # linkUserId = params[:user_id]
        # redirect_to "/attendance/success_out/#{linkUserId}"
        # ここまで、移行期間同期用
        redirect_to attendance_success_out_path
      end
    end
  end

  def error
    if current_user.role_id.slice(0) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    youbi = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日 日曜日]
    @date = Date.current.strftime("%Y年 %m月 %d日") + "( " +youbi[Date.today.wday] + " )"
  end
  def attendance_params
    params.permit(:user_id)
  end
  def auto
    if current_user.role_id.slice(0) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    youbi = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日 日曜日]
    @date = Date.current.strftime("%Y年 %m月 %d日") + "( " +youbi[Date.today.wday] + " )"
    @time = Time.now
  end
  def success_in
    if current_user.role_id.slice(0) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    youbi = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日 日曜日]
    @date = Date.current.strftime("%Y年 %m月 %d日") + "( " +youbi[Date.today.wday] + " )"
    # #ここから、以降期間の同期用
    # @linkUserId = params[:linkUserId]
    #ここまで、以降期間の同期用
  end  
  def success_out
    if current_user.role_id.slice(0) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    youbi = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日 日曜日]
    @date = Date.current.strftime("%Y年 %m月 %d日") + "( " +youbi[Date.today.wday] + " )"
    #ここから、以降期間の同期用
    # @linkUserId = params[:linkUserId]
    #ここまで、以降期間の同期用
  end  

end
