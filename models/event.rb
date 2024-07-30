class Event < ApplicationRecord
  belongs_to :organizer, class_name: 'User'
  has_many :event_participants
  has_many :users, through: :event_participants
end
