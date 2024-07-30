class EquipmentController < ApplicationController
  def list
    if current_user.role_id.slice(4) >= "0"
      @equipment = Equipment.order(id: :asc)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end
  def create
    size = "#{params[:size_hight]},#{params[:size_width]},#{params[:size_depth]}"
    @equipment = Equipment.new(name: params[:name],size: size,remark: params[:remark],category: params[:category],user_id: current_user.id)
    @equipment.save
    sizes = @equipment.size.split(",")
    c = params[:quantity].to_i
    equipmentItemIDs = []
    c.times do |num|
      @equipmentItem = EquipmentItem.new(equipment_id: @equipment.id,shelf_id: 1,user_id: current_user.id)
      @equipmentItem.save
      equipmentItemIDs = equipmentItemIDs.append(@equipmentItem.id)
    end
    equipmentItemIDs = equipmentItemIDs.join(',')
    flash[:alert] = "登録しました"
    redirect_to "/equipment/register"
  end
  def info
    @equipment = Equipment.find(params[:id])
    @equipmentItem = EquipmentItem.where(equipment_id: @equipment.id)
    equipmentItemIDs = []
    @equipmentItem.each do |item|
      equipmentItemIDs = equipmentItemIDs.append(item.id)
    end
    @equipmentItemIDs = equipmentItemIDs.join(',')
  end
end
