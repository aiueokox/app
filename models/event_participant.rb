class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum attendance_status: {
    unattended: 1,
    attended: 2,
    absent: 3
  }
end
