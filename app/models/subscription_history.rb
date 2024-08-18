class SubscriptionHistory < ApplicationRecord
  belongs_to :subscription
  belongs_to :staff

  enum :action, [ :created, :renewed, :activated ]
end
