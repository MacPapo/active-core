# frozen_string_literal: true

# Staff Model
class Staff < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :omniauthable
  devise :database_authenticatable, :timeoutable, :trackable, authentication_keys: [:nickname]
  belongs_to :user

  has_many :memberships, dependent: :nullify
  has_many :subscriptions, dependent: :nullify

  has_many :subscription_payments, through: :subscriptions
  has_many :membership_payments, through: :membership

  validates :nickname, :password, :role, presence: true

  enum :role, { contributor: 0, volunteer: 1, admin: 2 }, default: :contributor

  delegate :cf, :full_name, :name, :surname, 'med_cert_valid?',
           :age, :email, :phone, :birth_day, 'affiliated?',
           :med_cert_issue_date, :med_cert_exp_date, to: :user

  after_undiscard do
    user&.undiscard
  end

  scope :by_name, ->(query) do
    if query.present?
      where(
        'users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)',
        q: "%#{query}%",
        s: "%#{query.split.last}%",
        n: "%#{query.split.first}%"
      )
    end
  end

  scope :by_role, ->(role) do
    return unless role.present?

    where(role: role.to_sym)
  end

  scope :sorted, ->(sort_by, direction) do
    return unless %w[name surname birth_day updated_at].include?(sort_by)

    direction = %w[asc desc].include?(direction) ? direction : 'asc'
    sort_by = sort_by == 'updated_at' ? "staffs.#{sort_by}" : "users.#{sort_by}"
    order("#{sort_by} #{direction}")
  end

  def self.filter(params)
    case params[:visibility]
    when 'all'
      all
    when 'deleted'
      discarded
    else
      kept
    end.joins(:user)
      .by_name(params[:name])
      .by_role(params[:role])
      .sorted(params[:sort_by], params[:direction])
  end

  def active_for_authentication?
    super && !discarded?
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
