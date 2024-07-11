class Payment < ApplicationRecord
  before_validation :set_default_amount

  after_save :activate_membership_or_subscription
  after_initialize :set_default_date, if: :new_record?

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
    self.amount ||= amount_handler
  end

  def amount_handler
    case payable_type
    when "Membership"
      membership = Membership.find(payable_id)
      membership.cost
    when "Subscription"
      subscription = Subscription.find(payable_id)
      subscription.cost
    end
  end

  def activate_membership_or_subscription
    if self.payed
      case payable_type
      when "Membership"
        membership = Membership.find(payable_id)
        membership.update(state: :attivo)
      when "Subscription"
        subscription = Subscription.find(payable_id)
        subscription.update(state: :attivo)
      end
    end
  end
end
