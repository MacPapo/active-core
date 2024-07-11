class Membership < ApplicationRecord
  after_initialize :set_default_state, if: :new_record?

  belongs_to :user
  belongs_to :staff

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify

  enum state: [:inattivo, :attivo, :scaduto]

  validates :date, presence: true

  COST = 35.0

  def cost
    COST
  end

  def get_status
    self.state.to_sym
  end

  private

  def set_default_state
    self.state ||= :inattivo
  end
end
