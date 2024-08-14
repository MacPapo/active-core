# frozen_string_literal: true

class DeleteStaleLegalGuardiansJob < ApplicationJob
  queue_as :default

  def perform(*args)
    LegalGuardian.where.missing(:users).delete_all
  end
end
