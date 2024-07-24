class Activity < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :activity_plans, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # TODO rework activity and modify schema with index!!!
end
