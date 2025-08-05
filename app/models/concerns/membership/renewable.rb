module Membership::Renewable
  extend ActiveSupport::Concern

  included do
    scope :renewable, -> { where(status: [ :active, :expired ]) }
    scope :recently_renewed, -> { where.not(renewed_from_id: nil) }
  end

  def renewable?
    status.in?(%w[active expired]) && member.medical_certificate_valid?
  end

  def can_renew_early?
    active? && expires_soon?(30) # 30 days before expiration
  end

  def renewal_start_date
    expired? ? Date.current : end_date + 1.day
  end

  def create_or_renew_membership!(user:, payment_method:, pricing_plan:, discounts: [])
    last_membership = self.memberships.order(end_date: :desc).first

    if last_membership&.renewable?
     last_membership.renew!(user:, payment_method:, pricing_plan:, discounts:)
    else
      create_new!(user:, payment_method:, pricing_plan:, discounts:)
    end
  end

  def renewal_chain
    chain = [ self ]
    current = self

    # Get all previous renewals
    while current.renewed_from.present?
      current = current.renewed_from
      chain.unshift(current)
    end

    # Get all subsequent renewals
    current = self
    while (next_renewal = self.class.find_by(renewed_from: current))
      chain.push(next_renewal)
      current = next_renewal
    end

    chain
  end

  private

  def create_new!(user:, payment_method:, pricing_plan:, discounts:)
    ApplicationRecord.transaction do
      sport_year = SportYear.current
      membership = self.memberships.build( # SELF is MEMBER HERE
        user:,
        pricing_plan:,
        start_date: Date.current,
        end_date: sport_year.end_date,
        billing_period_start: sport_year.start_date,
        billing_period_end: sport_year.end_date,
        status: :pending
      )
      membership.save!

      payment = membership.register_payment(user:, payment_method:, discounts:)

      raise ActiveRecord::Rollback unless payment

      membership.update!(status: :active)
      membership
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_creation_error(e)
  end

  def handle_creation_error(e)
    Rails.logger.error "Membership creation failed: #{e.record.errors.full_messages}"
    errors.merge!(e.record.errors) if e.record != self

    nil
  end
end
