class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :staff

  enum payment_method: [:pos, :contanti, :bonifico, :indefinito]
  enum entry_type: [:entrata, :uscita]

  validates :amount,
            :date,
            :payment_method,
            :entry_type,
            :payed,
            :staff,
            presence: true

  after_save :activate_membership_or_subscription

  private

  # TODO test me

  def activate_membership_or_subscription
    case payable_type
    when "Membership"
      membership = Membership.find(payable_id)
      membership.update(payed: true)
    when "Subscription"
      subscription = Subscription.find(payable_id)
      subscription.update(payed: true)
    end
  end
end
