# frozen_string_literal: true

# Staff Model
class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :omniauthable
  devise :database_authenticatable, :timeoutable, :trackable, authentication_keys: [:nickname]
  belongs_to :user

  has_many :memberships, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many :subscription_payments, through: :subscriptions
  has_many :membership_payments, through: :membership

  validates :nickname, :password, :role, presence: true

  enum :role, %i[contributor volunteer admin], default: :contributor

  delegate :cf, :full_name, :name, :surname, 'med_cert_valid?',
           :age, :email, :phone, :birth_day, 'affiliated?',
           :med_cert_issue_date, :med_cert_exp_date, to: :user

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  # TODO rework
  def get_role
    role.to_sym
  end
end
