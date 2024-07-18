class Payment < ApplicationRecord
  after_initialize :set_default_date, if: :new_record?
  after_initialize :set_default_amount, if: :new_record?

  after_save :activate_membership_or_subscription

  belongs_to :payable, polymorphic: true
  belongs_to :staff

  enum payment_method: [:pos, :contanti, :bonifico, :indefinito]
  enum entry_type: [:entrata, :uscita]

  validates :payment_method, :entry_type, :payable, :staff, presence: true
  validates :payed, inclusion: { in: [ true, false ] }

  private

  def set_default_date
    self.date ||= Date.today
  end

  def set_default_amount
    p amount_handler
    self.amount ||= amount_handler
    p self.amount
  end

  def amount_handler
    case self.payable_type
    when "Membership"
      membership = Membership.find(self.payable_id)
      membership.cost
    when "Subscription"
      subscription = Subscription.find(self.payable_id)
      subscription.cost
    end
  end

  def activate_membership_or_subscription
      case payable_type
      when "Membership"
        membership = Membership.find(payable_id)
        membership.update(status: self.payed ? :attivo : :inattivo)
      when "Subscription"
        subscription = Subscription.find(payable_id)
        subscription.update(status: self.payed ? :attivo : :inattivo)
      end
  end
end
