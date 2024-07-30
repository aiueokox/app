class Equipment < ApplicationRecord
    belongs_to :user
    has_many :equipment_items
end
