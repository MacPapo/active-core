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

  enum :role, { contributor: 0, volunteer: 1, admin: 2 }, default: :contributor

  delegate :cf, :full_name, :name, :surname, 'med_cert_valid?',
           :age, :email, :phone, :birth_day, 'affiliated?',
           :med_cert_issue_date, :med_cert_exp_date, to: :user

  scope :by_name, ->(name) { where('users.name LIKE ?', "%#{name}%") if name.present? }
  scope :by_surname, ->(surname) { where('users.surname LIKE ?', "%#{surname}%") if surname.present? }
  scope :order_by_updated_at, ->(direction) { order("staffs.updated_at #{direction&.upcase}" )}

  def self.filter(name, surname, direction)
    joins(:user).by_name(name).by_surname(surname).order_by_updated_at(direction)
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  def humanize_role
    Staff.human_attribute_name("role.#{role}")
  end

  def self.humanize_roles
    roles.keys.map do |key|
      [Staff.human_attribute_name("role.#{key}"), key]
    end
  end
end
