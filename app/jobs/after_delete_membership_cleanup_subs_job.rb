# frozen_string_literal: true

# After Delete Membership Cleanup Subscriptions Job
class AfterDeleteMembershipCleanupSubsJob < ApplicationJob
  queue_as :real_time

  def perform(*args)
    users_to_update = Member.where.missing(:membership).joins(:subscriptions).distinct

    users_to_update.find_each { |user| user.subscriptions.destroy_all }
  end
end
