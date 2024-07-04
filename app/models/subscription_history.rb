class SubscriptionHistory < ApplicationRecord
  belongs_to :subscription
  belongs_to :staff

  validates :action, presence: true
  validates :action, inclusion: { in: %w[creazione rinnovo cancellazione] }
end
