class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :user
  has_many :subscriptions, dependent: :nullify
  has_many :subscription_histories, dependent: :nullify
  has_many :payments, dependent: :nullify

  validates :email, :password, :role, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is invalid' }

  enum role: [:collaboratore, :volontario, :admin]
  after_initialize :set_default_role, if: :new_record?
  def set_default_role
    self.role ||= :volontario
  end

  def full_name
    self.user.full_name
  end
end
