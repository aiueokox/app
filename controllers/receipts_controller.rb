class ReceiptsController < ApplicationController
  def index
    if current_user.role_id.slice(0) >= "3" || current_user.role_id.slice(3) >= "5"
    @receipts = Receipt.all
    WebLog.create(user_id: current_user.id, event_name: "receipt_index_displayed")
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end
end
