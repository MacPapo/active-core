class Membership < ApplicationRecord
  before_validation :set_end_date

  after_initialize :set_default_status, if: :new_record?
  after_initialize :set_default_date, if: :new_record?

  after_save :validate_status

  belongs_to :user
  belongs_to :staff

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify

  enum status: [:inattivo, :attivo, :scaduto]

  validates :start_date, presence: true

  COST = 35.0

  def cost
    COST
  end

  def get_status
    self.status.to_sym
  end

  def get_num_of_days_til_renewal
    (renewal_date - Date.today).to_i
  end

  def renewal_date
    self.end_date
  end

  private

  def set_default_status
    self.status ||= :inattivo
  end

  def set_default_date
    self.start_date ||= Date.today
  end

  def set_end_date
    numeric_next_year = ->(date) { (date + 1.year).year }
    self.end_date = Date.new(numeric_next_year.call(self.start_date), 9, 1)
  end

  def validate_status
    ValidateMembershipStatusJob.perform_later
  end
end
