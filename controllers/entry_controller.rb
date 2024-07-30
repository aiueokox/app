class EntryController < ApplicationController
  before_action :authenticate_user!, except: [:join,:term,:check]
  def invite
    # if current_user.role_id.slice(2) == "5"
    #   flash[:alert] = "権限がありません"
    #   redirect_to request.referer
    # end
    @checkTime = Time.now + 1800
    timeCode = Time.now.strftime('%H%M')
    inviteCode = "#{current_user.id * 37}-#{timeCode}"
    @inviteCode = inviteCode # これは文字列のまま扱います
  end

  def join
  end

  def term
  end

  def check
    inviteCode = params[:inviteCode]
    inviteCodeArray = inviteCode.split('-')
    inviteUser = inviteCodeArray[0].to_i / 37
    logger.debug "ああああああああ: #{inviteUser}"
    inviteTime = inviteCodeArray[1]
    logger.debug "ああああああああ: #{inviteTime}"
    timeCode = Time.now.strftime('%H%M')
    if inviteUser > 0
    user = User.find(inviteUser)
    else
      flash[:alert] = "不正な招待コードです(404 Not Fount)"
      redirect_to entry_join_path and return
    end
    unless user.role_id.slice(2) >= "2"
      flash[:alert] = "不正な招待コードです(401 Unauthorized)"
      redirect_to entry_join_path and return
    end
    if timeCode.to_i-inviteTime.to_i < 30
      session[:invite] = true 
      redirect_to new_user_registration_path
    else
      flash[:alert] = "不正な招待コードです(期限切れ)"
      redirect_to entry_join_path
    end
  end
end
