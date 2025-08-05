# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  include Discard::Model

  include ServiceLifecycle
  include Terminable
  include Member::Access
  include Membership::Renewable
  include Financial::BillingManagement, Financial::Payable

  # Associations
  belongs_to :user
  belongs_to :member
  belongs_to :pricing_plan
  belongs_to :renewed_from, class_name: "Membership", optional: true
  has_many :renewals, class_name: "Membership", foreign_key: "renewed_from_id"

  # Callbacks for automatic status management
  # after_create :activate_if_current TODO
  after_update :deactivate_expired_memberships

  def price
    pricing_plan.price
  end

  def renew!(user:, payment_method:, pricing_plan:, discounts:)
    previous_membership = self  # SELF is OLD_MEMBERSHIP HERE
    sport_year = SportYear.new(previous_membership.end_date + 1.day)

    ApplicationRecord.transaction do
      new_membership = previous_membership.member.memberships.build(
        user:,
        pricing_plan:,
        renewed_from: previous_membership,
        start_date: Date.current,
        end_date: sport_year.end_date,
        billing_period_start: sport_year.start_date,
        billing_period_end: sport_year.end_date,
        status: :pending
      )
      new_membership.save!

      payment = new_membership.register_payment(user:, payment_method:, discounts:)

      raise ActiveRecord::Rollback unless payment

      new_membership.update!(status: :active)
      previous_membership.update!(status: :expired)

      new_membership
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_creation_error(e)
  end

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
