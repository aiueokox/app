class CardInfosController < ApplicationController
  before_action :authenticate_user!  # Deviseのヘルパーでユーザーの認証を強制します

  def new
    if current_user.role_id.slice(0) >= "3" || current_user.role_id.slice(3) >= "5"
      @card_info = CardInfo.new
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def create
    @card_info = CardInfo.new(card_info_params)
    @card_info.user_id = current_user.id  # ログインしているユーザーのIDを設定

    if @card_info.save
      Rails.logger.debug("Card info saved successfully")
      redirect_to card_infos_path, notice: 'カード情報が正常に保存されました。'
      WebLog.create(user_id: current_user.id, event_name: "account_created")
    else
      render :new
    end
  end

  def index
    if current_user.role_id.slice(0) >= "3" || current_user.role_id.slice(3) >= "5"
      @card_info = CardInfo.order(created_at: :desc).first
      WebLog.create(user_id: current_user.id, event_name: "account_index_displayed")
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  private

  def card_info_params
    params.require(:card_info).permit(:card_brand, :card_holder_name, :card_number, :expiration_date, :security_code)
  end
end
