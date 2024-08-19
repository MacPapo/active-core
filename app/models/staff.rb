# frozen_string_literal: true

class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :omniauthable
  devise :database_authenticatable, :timeoutable, :trackable, :authentication_keys => [:nickname]
  belongs_to :user

  has_many :memberships, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many :subscription_payments, through: :subscriptions
  has_many :membership_payments, through: :membership

  validates :nickname, :password, :role, presence: true

  enum :role, [ :contributor, :volunteer, :admin ], default: :contributor

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  def full_name
    self.user.full_name
  end

  def get_name
    self.user.name
  end

  def get_surname
    self.user.surname
  end

  def get_birth_day
    self.user.birth_day
  end

  # TODO rework
  def get_role
    self.role.to_sym
  end

  def get_cf
    self.user.cf
  end

  def get_phone
    self.user.phone
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
