class PlansForActivity < ApplicationRecord
  belongs_to :activity
  belongs_to :subscription_type

  validates :activity, :subscription_type, :duration, :cost, presence: true
end
