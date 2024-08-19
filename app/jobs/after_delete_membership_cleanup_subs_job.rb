# frozen_string_literal: true

class AfterDeleteMembershipCleanupSubsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    users_to_update = User
                        .where.missing(:membership)
                        .joins(:subscriptions)
                        .distinct

    users_to_update.find_each do |user|
      user.subscriptions.destroy_all
    end
  end
end
