# frozen_string_literal: true

# Subscription History Model
class SubscriptionHistory < ApplicationRecord
  belongs_to :subscription
  belongs_to :staff

  enum :action, { created: 0, renewed: 1, activated: 2 }
end
