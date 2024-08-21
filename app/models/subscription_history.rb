# frozen_string_literal: true

# Subscription History Model
class SubscriptionHistory < ApplicationRecord
  belongs_to :subscription
  belongs_to :staff

  enum :action, %i[created renewed activated]
end
