class Course < ApplicationRecord
    belongs_to :college, optional: true
    #has_one :college
    has_one :profile
end
