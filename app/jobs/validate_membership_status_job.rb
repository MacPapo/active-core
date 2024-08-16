# frozen_string_literal: true

class ValidateMembershipStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
    memberships_to_update = Membership.where(status: :active).where("end_date < ?", Date.today)

    memberships_to_update.find_each do |membership|
      membership.update(status: :expired)
    end
  end
end
