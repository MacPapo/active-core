class SubscriptionHistory < ApplicationRecord
  # TODO Do I have to insert also user reference?
  belongs_to :subscription
  belongs_to :staff

  enum action: [:creazione, :rinnovo, :cancellazione]
end
