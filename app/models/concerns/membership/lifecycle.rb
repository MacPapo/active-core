module Membership::Lifecycle
  extend ActiveSupport::Concern

  def create_or_renew_membership!(user:, payment_method:, pricing_plan:)
    previous_membership = current_membership

    if previous_membership
      renew!(previous_membership, user, payment_method, pricing_plan)
    else
      create_new!(user, payment_method, pricing_plan)
    end
  end

  private

  def create_new!(user, payment_method, pricing_plan)
    ApplicationRecord.transaction do
      membership = build_membership(user, pricing_plan)
      process_transaction!(membership, user, payment_method)
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_creation_error(e)
  end

  def renew!(previous, user, payment_method, pricing_plan)
    ApplicationRecord.transaction do
      new_membership = build_membership(user, pricing_plan, previous)
      process_transaction!(new_membership, user, payment_method)
      previous.update!(status: :expired)
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_creation_error(e)
  end

  def build_membership(user, pricing_plan, previous_membership = nil)
    sport_year = previous_membership ? SportYear.new(previous_membership.end_date + 1.day) : SportYear.current

    memberships.build(
      user: user,
      pricing_plan: pricing_plan,
      renewed_from: previous_membership,
      start_date: Date.current,
      end_date: sport_year.end_date,
      billing_period_start: sport_year.start_date,
      billing_period_end: sport_year.end_date,
      amount_paid: pricing_plan.price,
      status: :pending
    )
  end

  def process_transaction!(membership, user, payment_method)
    membership.save!
    process_membership_payment!(membership, payment_method, user)
    membership.update!(status: :active)
  end

  def handle_creation_error(e)
    Rails.logger.error "Membership creation failed: #{e.record.errors.full_messages}"
    errors.merge!(e.record.errors) if e.record != self
    raise ActiveRecord::Rollback
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
