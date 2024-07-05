class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :user, optional: true
  has_many :subscription_histories, dependent: :nullify
  has_many :payments, dependent: :nullify

  enum role: [:collaboratore, :volontario, :admin]
  after_initialize :set_default_role, :if => :new_record?
  def set_default_role
    self.role ||= :volontario
  end

  validates :role, presence: true
end
