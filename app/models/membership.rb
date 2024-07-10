class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_type

  has_many :payments, as: :payable, dependent: :nullify

  def cost
    35.0
  end
end
