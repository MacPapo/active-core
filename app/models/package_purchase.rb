# frozen_string_literal: true

# PackagePurchase Model
class PackagePurchase < ApplicationRecord
  include Discard::Model

  include Terminable
  include Member::Access
  include Package::Integration
  include Financial::Payable, Financial::BillingManagement

  belongs_to :member
  belongs_to :package
  belongs_to :user
  has_many :payment_items, as: :payable, dependent: :destroy
  has_many :payments, through: :payment_items
  has_many :registrations, dependent: :destroy

  validates :start_date, :end_date, :billing_period_start, :billing_period_end, presence: true

  scope :for_member, ->(member) { where(member: member) }
  scope :for_package, ->(package) { where(package: package) }
  scope :active_purchases, -> { where(status: :active) }

  after_create :create_package_registrations!
  after_update :update_registration_status!, if: :saved_change_to_status?

  def description
    "#{package.name} - #{member.full_name}"
  end

  def price
    is_affiliated = self.member&.affiliated?

    if is_affiliated && package.affiliated_price.present?
      package.affiliated_price
    else
      package.price
    end
  end

  def total_sessions_included
    package.package_inclusions.where.not(session_limit: nil).sum(:session_limit)
  end

  def included_products
    package.products
  end

  def package_value
    package.price
  end

  def balance_due
    paid_amount = payments.sum(:final_amount)
    package.price - paid_amount
  end

  private

  def create_package_registrations!
    return unless status_active?

    package.create_registrations_for!(member, user)
  end

  def update_registration_status!
    case status
    when "cancelled", "suspended"
      registrations.where(status: :active).update_all(status: status)
    when "active"
      registrations.where(status: [ :cancelled, :suspended ]).update_all(status: :active)
    end
  end
end
