# frozen_string_literal: true

# Activate Thing Job
class ActivateThingJob < ApplicationJob
  queue_as :real_time

  def perform(*args)
    type, eid = args

    case type
    when 'mem'
      membership = Membership.find(eid)
      membership.active!
    when 'sub'
      subscription = Subscription.find(eid)
      subscription.active!

      subscription.open_subscription&.active! if subscription.open?
    end
  end
end
