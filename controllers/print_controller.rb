class PrintController < ApplicationController
  def identityCard
    if current_user.role_id.slice(2) >= "5"
    @profile = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: params[:id],status: nil).first
    @president = Profile.where(leaved_at: nil, status: nil, department_id: "40").order(id: :desc).first
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def equipmentLabel
    if params[:equipmentItemIDs].present?
      @equipmentItemIDs = params[:equipmentItemIDs].split(',').to_a
      @equipmentItemID =  @equipmentItemIDs[0]
      @equipmentItem = EquipmentItem.where(id: @equipmentItemID).includes(:equipment).limit(1)
      @equipmentItemIDs.delete_at(0)
      @equipmentItemIDs = @equipmentItemIDs.join(',')
      @redirect = "/print/equipmentLabel/#{params[:equipment_id]}/#{@equipmentItemIDs}"
    else
      redirect_to "/equipment/info/#{params[:equipment_id]}"
    end
  end

  def receipt
    if current_user.role_id.slice(0) >= "3" || current_user.role_id.slice(3) >= "5"
    @receipt = Receipt.find(params[:id])
    # last_displayed_atに現在時刻をセット
    @receipt.update(last_displayed_at: Time.now)
    WebLog.create(user_id: current_user.id, event_name: "receipt_displayed", value1: @receipt.id)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end
end
