class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :subscription_type

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, dependent: :nullify

  enum state: [:attivo, :scaduto, :cancellato]
  after_initialize :set_default_state, :if => :new_record?
  def set_default_state
    self.state ||= :attivo
  end

  validates :state, presence: true
end
