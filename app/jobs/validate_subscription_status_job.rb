# frozen_string_literal: true

# Validate Subscription Status Job
class ValidateSubscriptionStatusJob < ApplicationJob
  queue_as :background

  def perform(*)
    subscriptions_to_updates = Subscription.where(status: :active).where('end_date < ?', Time.zone.today)

    subscriptions_to_updates.find_each(&:expired!)
  end
end
