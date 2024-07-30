class EquipmentItem < ApplicationRecord
    belongs_to :user
    belongs_to :equipment
    belongs_to :shelf
end
