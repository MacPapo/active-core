# frozen_string_literal: true

# Delete Stale Legal Guardians Job
class DeleteStaleLegalGuardiansJob < ApplicationJob
  queue_as :background

  def perform(*)
    LegalGuardian.where.missing(:users).delete_all
  end
end
