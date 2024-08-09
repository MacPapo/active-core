class Payment < ApplicationRecord
  after_initialize :set_default_date, if: :new_record?

  after_save :activate_membership_or_subscription

  belongs_to :payable, polymorphic: true
  belongs_to :staff

  enum :payment_method, [ :pos, :contanti, :bonifico ], default: :contanti
  enum :entry_type, [ :entrata, :uscita ], default: :entrata

  validates :payment_method, :entry_type, :payable, :staff, presence: true
  validates :payed, inclusion: { in: [ true, false ] }

  private

  def set_default_date
    self.date ||= Date.today
  end

  def self.humanize_payment_methods
    payment_methods.keys.map do |key|
      [I18n.t("activemodel.enums.payment.payment_method.#{key}"), key]
    end
  end

  def self.humanize_entry_types
    entry_types.keys.map do |key|
      [I18n.t("activemodel.enums.payment.entry_type.#{key}"), key]
    end
  end

  # TODO undo activation if payment is destroyed
  def activate_membership_or_subscription
    return unless self.payed

    case payable_type
    when "Membership"
      membership = Membership.find(payable_id)
      membership.attivo!
    when "Subscription"
      subscription = Subscription.find(payable_id)
      subscription.attivo!
    end
  end
end
