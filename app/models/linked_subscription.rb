# frozen_string_literal: true

class LinkedSubscription < ApplicationRecord
  belongs_to :subscription, dependent: :destroy
  belongs_to :open_subscription, class_name: 'Subscription', dependent: :destroy

  validates :subscription_id, presence: true
  validates :open_subscription_id, presence: true
end
