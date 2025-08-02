module MembershipLifecycle
  extend ActiveSupport::Concern

  def create_annual_membership!(user:, payment_method:, pricing_plan:)
    sport_year = SportYear.current

    ApplicationRecord.transaction do
      save!
      membership = build_annual_membership(sport_year, user, pricing_plan)
      membership.save!
      process_membership_payment!(membership, payment_method, user)
      membership.update!(status: :active)
      self
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "Membership creation failed: #{e.record.errors.full_messages}"
    errors.merge!(e.record.errors) if e.record != self
    raise ActiveRecord::Rollback
  end

  def renew_annual_membership!(user:, payment_method:, pricing_plan:)
    current = current_membership
    return create_annual_membership!(user:, payment_method:, pricing_plan:) unless current

    next_sport_year = SportYear.new(current.end_date + 1.day)

    ApplicationRecord.transaction do
      save!
      new_membership = build_renewal_membership(current, next_sport_year, user, pricing_plan)
      new_membership.save!
      process_membership_payment!(new_membership, payment_method, user)
      new_membership.update!(status: :active)
      current.update!(status: :expired)
      new_membership
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "Membership creation failed: #{e.record.errors.full_messages}"
    errors.merge!(e.record.errors) if e.record != self
    raise ActiveRecord::Rollback
  end

  private

  def build_annual_membership(sport_year, user, pricing_plan)
    memberships.build(
      user: user,
      pricing_plan: pricing_plan,
      start_date: Date.current,
      end_date: sport_year.end_date,
      billing_period_start: sport_year.start_date,
      billing_period_end: sport_year.end_date,
      amount_paid: pricing_plan.price,
      status: :pending
    )
  end

  def build_renewal_membership(previous, sport_year, user, pricing_plan)
    memberships.build(
      user: user,
      pricing_plan: pricing_plan,
      renewed_from: previous,
      start_date: Date.current,
      end_date: sport_year.end_date,
      billing_period_start: sport_year.start_date,
      billing_period_end: sport_year.end_date,
      amount_paid: pricing_plan.price,
      status: :pending
    )
  end

  def process_membership_payment!(membership, payment_method, user)
    payment = Payment.new(
      user: user,
      total_amount: membership.amount_paid,
      discount_amount: 0,
      final_amount: membership.amount_paid,
      date: Date.current,
      payment_method: payment_method,
      income: true
    )

    payment.payment_items.build(
      payable: membership,
      amount: membership.amount_paid,
      description: "Membership Annuale #{SportYear.current.year}-#{SportYear.current.year + 1} - #{full_name}"
    )

    payment.save!
    payment
  end
end
