class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :subscription_type
end
