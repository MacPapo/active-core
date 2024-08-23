# frozen_string_literal: true

# Detach Legal Guardians Job
class DetachLegalGuardiansJob < ApplicationJob
  queue_as :background

  def perform(*)
    users_to_update = User.joins(:legal_guardian)
                          .where('? - users.birth_day >= 18', Time.zone.today)

    users_to_update.find_each { |u| u.update(legal_guardian_id: nil) }
  end
end
