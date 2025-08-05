# app/models/concerns/registration/renewable.rb
module Registration::Renewable
  extend ActiveSupport::Concern

  included do
    scope :renewable, -> { where(status: [ :active, :expired ]) }
    scope :package_based, -> { where.not(package_id: nil) }
    scope :standalone, -> { where(package_id: nil) }
  end

  def renewable?
    status.in?(%w[active expired]) && member.can_register_for_product?(product)
  end

  def can_renew_early?
    active? && expires_soon?(7) # 7 giorni per registrations
  end

  # TODO localization
  def create_or_renew_registration!(user:, payment_method:, package: nil, product: nil, pricing_plan: nil, discounts: [])
    if package.nil? && product.present?
      unless self.can_register_for_product?(product)
        errors.add(:base, "Membership richiesta o non valida per questo prodotto.")
        return nil
      end
    end

    if package.present?
      create_package_based_registration!(user: user, payment_method: payment_method, package: package, discounts: discounts)
    else
      return nil unless product && pricing_plan
      create_standalone_registration!(user: user, payment_method: payment_method, product: product, pricing_plan: pricing_plan, discounts: discounts)
    end
  end

  private

  def create_standalone_registration!(user:, payment_method:, product:, pricing_plan:, discounts:)
    validate_standalone_requirements!(product)

    ApplicationRecord.transaction do
      registration = self.registrations.build( # SELF is MEMBER HERE
        product:,
        pricing_plan:,
        user:,
        start_date: Date.current,
        end_date: pricing_plan.calculate_end_date(Date.current),
        billing_period_start: Date.current,
        billing_period_end: pricing_plan.calculate_end_date(Date.current),
        sessions_remaining: pricing_plan.session_limit,
        status: :pending
      )
      registration.save!

      payment = registration.register_payment(user:, payment_method:, discounts:)

      raise ActiveRecord::Rollback unless payment

      registration.update!(status: :active)
      registration
    end
  end

  def create_package_based_registration!(user:, payment_method:, package:, discounts:)
    validate_package_requirements!(package)

    ApplicationRecord.transaction do
      package_purchase = self.package_purchases.build(
        package:,
        user:,
        start_date: Date.current,
        end_date: package.calculate_end_date(Date.current),
        billing_period_start: Date.current,
        billing_period_end: package.calculate_end_date(Date.current),
        status: :pending
      )
      package_purchase.save!

      payment = package_purchase.register_payment(user:, payment_method:, discounts:)

      raise ActiveRecord::Rollback unless payment

      package_purchase.update!(status: :active)
      package.create_registrations_for!(self, user)

      package_purchase
    end
  end

  # Validations
  def validate_standalone_requirements!(product)
    raise "Membership richiesta" unless can_register_for_product?(product)
    raise "Prodotto al completo" unless product.can_accept_registration?
  end

  def validate_package_requirements!(package)
    raise "Package non disponibile" unless package.available_for_purchase?
  end
end
