class Activity < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :activity_plans, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :num_participants, presence: true
  validates :num_participants, numericality: { greater_than: 0 }

  # TODO rework activity and modify schema with index!!!
end
