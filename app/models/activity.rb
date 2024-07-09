class Activity < ApplicationRecord
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
