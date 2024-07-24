class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :user

  has_many :memberships, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscription_payments, through: :subscriptions
  has_many :membership_payments, through: :membership

  validates :email, :password, :role, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is invalid' }
  normalizes :email, with: -> { _1.strip.downcase }

  enum role: [:collaboratore, :volontario, :admin]
  after_initialize :set_default_role, if: :new_record?
  def set_default_role
    self.role ||= :volontario
  end

  def full_name
    self.user.full_name
  end

  def get_role
    self.role.to_sym
  end

  def get_formatted_role
    self.role.capitalize
  end

  def get_cf
    self.user.cf
  end

  def get_phone
    self.user.phone
  end

  def get_date_of_birth
    self.user.date_of_birth.strftime("%d/%m/%Y")
  end

  def get_age
    self.user.age
  end

  def get_med_cert
    self.user.med_cert_issue_date
  end

  def is_med_cert_valid?
    self.user.med_cert_valid?
  end

  def is_affiliated?
    self.user.is_affiliated?
  end
end
