class EquipmentItemController < ApplicationController
  def list
    if current_user.role_id.slice(4) >= "0"
      # @equipmentItems = EquipmentItem.order(id: :asc)
      # @equipmentItems = Equipment.joins(equipment_items: :shelf).select("equipment.*, equipment_items.*, shelves.*").order(id: :asc)
      @equipmentItems = EquipmentItem.joins(:equipment, :shelf).select("equipment.name,equipment.size,equipment.category,equipment.image, equipment_items.*, shelves.room").order(id: :asc)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end
end
