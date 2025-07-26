# frozen_string_literal: true

# Cleanup EOL Records from DB
class CleanupEolRecordsJob < ApplicationJob
  queue_as :default

  TARGET_CLASSES =
    %w[User Staff Membership Subscription Payment
       PaymentMembership PaymentSubscription
       ReceiptMembership ReceiptSubscription
       Activity ActivityPlan Receipt].freeze

  def perform
    TARGET_CLASSES.each { |cname| Object.const_get(cname).where("discarded_at < ?", 10.years.ago).destroy_all }
  end
end
