# frozen_string_literal: true

# Activate Thing Job
class ActivateThingJob < ApplicationJob
  queue_as :real_time

  def perform(*args)
    payable_type, payable_id = args

    case payable_type
    when 'Membership'
      membership = Membership.find(payable_id)
      membership.active!
    when 'Subscription'
      subscription = Subscription.find(payable_id)
      subscription.active!

      subscription.open_subscription&.active! if subscription.open?
    end
  end
end
