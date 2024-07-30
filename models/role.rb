class Role < ApplicationRecord
    belongs_to :department, optional: true
end
