# frozen_string_literal: true

class DetachLegalGuardiansJob < ApplicationJob
  queue_as :default

  def perform(*args)
    users_to_update = User
                        .joins(:legal_guardian)
                        .where("? - users.birth_day >= 18", Date.today)

    users_to_update.find_each do |user|
      user.update(legal_guardian: nil)
    end
  end
end
