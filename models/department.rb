class Department < ApplicationRecord
    has_one :profile
    has_one :role

    def view_department_and_position
        self.department + '　' + self.position.to_s
    end
end
