class ProfileController < ApplicationController

  def member_count
    member = User.joins(:profile).where(profiles: { status: nil , leaved_at: nil }).and(Profile.where.not(image: nil)).and(User.where("role_id LIKE ?", "2%")) 
    @member_statistics = member.group(:course_id).count
    @members_sex = member.group(:sex).count
    @members_all = member
  end

  def headcount
    @member_statistics = Profile.where(status: nil, leaved_at: nil).group(:course_id).count
    @members_sex = Profile.where(status: nil, leaved_at: nil).group(:sex).count
    @members_all = Profile.where(status: nil, leaved_at: nil).select(:user_id) 
  end

  def info
    @profile = User.includes(profile: { department: {}, course: :college })
           .where(id: params[:id])
           .where(profiles: { status: nil })
           .order('profiles.created_at DESC')
           .first
    unless @profile.id == current_user.id || current_user.role_id.slice(2) >= "3"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    unless current_user.role_id.slice(0) == "4" || @profile.id == current_user.id
      WebLog.new(event_name: "profile_info", user_id: current_user.id, value1: @profile.id).save
    end
    @logs = WebLog
    .select("web_logs.id, web_logs.event_name, web_logs.created_at, users.id AS user_id, profiles.username AS profile_username")
    .joins(:user)
    .joins("INNER JOIN (SELECT p1.* FROM profiles p1 LEFT JOIN profiles p2 ON p1.user_id = p2.user_id AND p1.created_at < p2.created_at WHERE p2.id IS NULL AND p1.status IS NULL) profiles ON profiles.user_id = users.id")
    .where(event_name: ["profile_info", "profile_picture"], value1: @profile.id)
    .where("web_logs.created_at = (SELECT MAX(wl.created_at) FROM web_logs wl WHERE wl.id = web_logs.id AND wl.user_id = users.id)")
    .order("web_logs.created_at DESC")
    .limit(10)
  

  end

  def list
    if current_user.role_id.slice(2) >= "2"
      @profiles = Profile.joins(:user).select("profiles.*, users.role_id").where(status: nil,leaved_at: nil,).and(Profile.where.not(image: nil)).and(User.where("role_id LIKE ?", "2%")).order(user_id: :asc)
      @search_params = profile_search_params
      @profile_search = @profiles.search(@search_params)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def masterlist
    if current_user.role_id.slice(2) >= "5"
      @profiles = Profile.joins(:user).select("profiles.*, users.role_id").where(status: nil,leaved_at: nil,).and(Profile.where.not(image: nil)).and(User.where("role_id LIKE ?", "2%")).order(user_id: :asc)
      @search_params = profile_all_search_params
      @profile_search = @profiles.search(@search_params)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def account_list
    if current_user.role_id.slice(5) >= "2" || current_user.role_id.slice(2) >= "5" 
      @profiles = Profile.joins(:user).select("profiles.*, users.*").where(status: nil).order("users.id ASC")
      @search_params = account_search_params
      @users = @profiles.search(@search_params)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def master_login
    if current_user.role_id.slice(0) == "4"
      @user = User.find(params[:id])
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def leaved
    if current_user.role_id.slice(2) >= "5"
      @profile = Profile.where(user_id: params[:id],status: nil).order(updated_at: :desc).limit(1).first
      @profile.update(leaved_at: Time.now)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    redirect_to "/profile/info/#{@profile.user_id}"
  end

  def entry
    if current_user.role_id.slice(2) >= "2"
      @profiles = Profile.joins(:user).select("profiles.*, users.role_id").where(status: nil,image: nil,leaved_at: nil).and(User.where("role_id LIKE ?", "2%")).order(user_id: :asc)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def edit
    if current_user.role_id.slice(5) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @user = Profile.where(user_id: params[:id],status: nil).order(created_at: :desc).limit(1).first
    @post = Profile.new 
  end

  def reqEdit
    @user = Profile.where(user_id: current_user.id,status: nil).order(created_at: :desc).limit(1).first
    @post = Profile.new 
  end

  def imageup
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @user = Profile.where(user_id: params[:id],status: nil).order(created_at: :desc).limit(1).first
    @post = Profile.new
  end

  def UserUpdate
    ActiveRecord::Base.transaction do
      @item = Profile.where(user_id: params[:user_id],status: nil).order(created_at: :desc).limit(1).first
      @item.update!(status: "no",updated_at: params[:updated_at])
      @profile = Profile.new(profile_params)
      @profile.save!
      redirect_to "/profile/info/#{@profile.user_id}"
    end
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "更新に失敗しました"
    redirect_to request.referer
  end

  def reqUserUpdate
    service = UpdateProfileRequestService.new(current_user, profile_params)
    service.create_request
    redirect_to "/profile/info/#{profile_params[:user_id]}"
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "更新に失敗しました"
    redirect_to request.referer
  end

  def reqDo
    unless current_user.role_id.slice(2) >= "6"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    request = Request.find(params[:id])
    service = UpdateProfileRequestService.new(current_user, nil)
    service.approve(request)
    redirect_to "/profile/info/#{request.target}"
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "承認に失敗しました"
    redirect_to request.referer
  end

  def reqDeny
    unless current_user.role_id.slice(2) >= "6"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    request = Request.find(params[:id])
    service = UpdateProfileRequestService.new(current_user, nil)
    service.deny(request)
    redirect_to "/profile/info/#{request.target}"
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "否認に失敗しました"
    redirect_to request.referer
  end

  def reqConectID
    @user = User.find(params[:id])
  end

  def newReqConectID
    record = Request.create!(user_id: current_user.id, title: "ID連携リクエスト", kind: "hr_ConectID", target: params[:id], value: params[:email])
    user = Profile.find_by(user_id: params[:id])
    
    approver = User.where("SUBSTRING(role_id, 5, 1) >= '3'").pluck(:id)
  
    approver.each do |approver_id|
      user_id = approver_id
      message = ":page_with_curl:*WF作成通知* \n 内容を確認して対応してください。\n>申請No：<https://action-club.jp/request/info/#{record.id}|#{format("%05d", record.id)} >\n>WF名：#{record.title} \n>申請日時：#{record.created_at.strftime('%Y-%m-%d %H:%M')}\n>WF作成者：<https://action-club.jp/profile/info/#{record.user_id}|#{user.username}（#{format("%06d", record.user_id)}）>"
      result1 = SlackSendMessageToUserService.send_message_to_user(user_id, message)
    end
    
    redirect_to "/profile/info/#{params[:id]}"
  end
  
  def reqConectIDDo
    request = Request.find(params[:id])
    user = User.find(request.target)
    user.update!(email: request.value)
    request.update!(status: "success", approver: current_user.profile.username)
    user_id = request.user_id
    message = ":white_check_mark:*申請が承認されました* \n 内容を確認してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)}>\n>WF名：#{request.title} \n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')} >\n>処理日時：#{Time.now} \n>WF処理者：#{current_user.profile.username}"
    result1 = SlackSendMessageToUserService.send_message_to_user(user_id, message)
    redirect_to "/profile/info/#{request.target}"
  end

  def reqConectIDDeny
    request = Request.find(params[:id])
    request.update!(status: "danger", approver: current_user.profile.username)
    user_id = request.user_id
    message = ":negative_squared_cross_mark:*申請が否決されました* \n 内容を確認して必要であれば再申請してください。\n>申請No：<https://action-club.jp/request/info/#{request.id}|#{format("%05d", request.id)} >\n>WF名：#{request.title}\n>申請日時：#{request.created_at.strftime('%Y-%m-%d %H:%M')}\n>処理日時：#{Time.now} \n>WF処理者：#{current_user.profile.username}"
    result1 = SlackSendMessageToUserService.send_message_to_user(user_id, message)
    redirect_to "/profile/info/#{request.target}"
  end

  def assignment
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @grantProfile = Profile.where(user_id: params[:id], status: nil).first
  end

  def grant
    @grantUser = Profile.find(params[:id])
    @grantUser.update(department_id: params[:dept_id])
    flash[:alert] = "付与が完了しました"
    redirect_to root_path
  end

  def dept_select

  end

  def dept_designation
    redirect_to select_staff_dept_designations_path(params[:dept_id]), notice: '所属プリセットが指定されました。次に会員を選択してください。'
  end

  def select_staff_dept_designations
    # 部署のプリセットを取得
    @dept = Department.find(params[:id])
    @users = User.joins(profile: [:course, :department]).where(profiles: { status: nil , leaved_at: nil }).and(User.where("role_id LIKE ?", "2%"))
  end

  def add_staff_dept_designations
    ActiveRecord::Base.transaction do
        # パラメータからuser_idsを取得
        user_ids = params[:dept]&.dig(:user_ids)&.reject(&:blank?)

        # user_idsが存在する場合のみ、それに対応するevent_participantsを作成
        if user_ids
          user_ids.each do |user_id|
              # Profile.statusをnoに変更し、department_idのみを変更した新たなレコードを作成
              @profile = Profile.where(user_id: user_id, status: nil).order(created_at: :desc).limit(1).first
              existing_image = Profile.find_by(user_id: user_id, status: nil).try(:image)
              @profile.update!(status: "no")

              # @profileを元に、department_idを変更した新たなレコードを作成
              @new_profile = Profile.new(
                user_id: @profile.user_id,
                username: @profile.username,
                ruby: @profile.ruby,
                first_name: @profile.first_name,
                last_name: @profile.last_name,
                nickname: @profile.nickname,
                dob: @profile.dob,  # 修正箇所
                sex: @profile.sex,
                phone: @profile.phone,
                student_num: @profile.student_num,
                teacher_name: @profile.teacher_name,
                commute: @profile.commute,
                parent_name: @profile.parent_name,
                parent_phone: @profile.parent_phone,
                parent_address: @profile.parent_address,
                status: nil,
                course_id: @profile.course_id,
                department_id: params[:id],
                created_at: @profile.created_at,
                updated_at: @profile.updated_at,
                leaved_at: @profile.leaved_at
              )
              if @profile.image?
                @new_profile.image = existing_image if existing_image
              end

              @new_profile.save!
          end
          redirect_to profile_list_path, notice: '所属プリセットの登録が完了しました'
        else
          redirect_to select_staff_dept_designations_path(params[:id]), alert: '会員が選択されていません'
        end
    end          
  end

  def new
    session[:previous_url] = request.referer  # ここで前ページセッションを保存
  end

  def create
    redirect_to session[:previous_url]  # create後に遷移させる
  end

  private
  def profile_params #ストロングパラメータ
    params.permit(:department_id,:kind,:status,:image,:updated_at,:leaved_at,:created_at,:user_id, :username, :ruby,:first_name,:last_name,:nickname,:dob,:sex,:phone,:student_num,:course_id,:teacher_name,:commute,:parent_name,:parent_phone,:parent_address)
  end
  def request_params
    params.require(:request).permit(:status, :approver)
  end
end

def profile_search_params
  params.fetch(:search, {}).permit(:user_id, :ruby, :nickname, :sex, :college_id, :course_id, :department_id)
end

def profile_all_search_params
  params.fetch(:search, {}).permit(:user_id, :ruby, :nickname, :sex, :college_id, :course_id, :department_id, :commute)
end

def account_search_params
  params.fetch(:search, {}).permit(:user_id, :ruby, :email, :sign_in_count, :role_id, :sign_in_ip)
end

