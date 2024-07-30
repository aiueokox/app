class College < ApplicationRecord
    #belongs_to :course, optional: true
    has_one :course
end
