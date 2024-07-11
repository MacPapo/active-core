class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :staff

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify

  validates :date, presence: true

  COST = 35.0

  def cost
    COST
  end
end
