# frozen_string_literal: true

# Validate Membership Status Job
class ValidateMembershipStatusJob < ApplicationJob
  queue_as :background

  # TODO Guarda se corretto
  def perform(*)
    memberships_to_update = Membership.where(status: :active).where("end_date < ?", Time.zone.today)

    memberships_to_update.find_each(&:expired!)
  end
end
