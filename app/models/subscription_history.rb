class SubscriptionHistory < ApplicationRecord
  # TODO Do I have to insert also user reference?
  belongs_to :subscription
  belongs_to :staff

  enum :action, [ :creation, :renewal, :cancellation ]
end
