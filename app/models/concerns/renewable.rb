module Renewable
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

  def renew!(pricing_plan:, user:)
    raise "Cannot renew this membership" unless renewable?

    transaction do
      new_membership = self.class.create!(
        member: member,
        pricing_plan: pricing_plan,
        user: user,
        renewed_from: self,
        start_date: renewal_start_date,
        end_date: pricing_plan.calculate_end_date(renewal_start_date),
        billing_period_start: renewal_start_date,
        billing_period_end: pricing_plan.calculate_end_date(renewal_start_date),
        amount_paid: pricing_plan.price_for(member),
        status: :active
      )

      update!(status: :expired) if active?
      new_membership
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
end
