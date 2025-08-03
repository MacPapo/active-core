# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  include Discard::Model
  include Member::Access
  include SubscriptionLifecycle
  include Renewable
  include Financial::BillingManagement

  # Associations
  belongs_to :user
  belongs_to :member
  belongs_to :pricing_plan
  belongs_to :renewed_from, class_name: "Membership", optional: true
  has_many :renewals, class_name: "Membership", foreign_key: "renewed_from_id"

  # Callbacks for automatic status management
  # after_create :activate_if_current TODO
  after_update :deactivate_expired_memberships

  private

  def activate_if_current
    update!(status: :active) if current? && pending?
  end

  def deactivate_expired_memberships
    return unless saved_change_to_status? && active?

    # Deactivate other active memberships for the same member
    member.memberships.where.not(id: id).active.update_all(status: :expired)
  end
end
