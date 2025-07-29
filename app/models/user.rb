# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :omniauthable
  devise :database_authenticatable, :timeoutable, :trackable, authentication_keys: [ :nickname ]

  # Associations
  belongs_to :member
  has_many :payments, dependent: :restrict_with_error
  has_many :receipts, dependent: :restrict_with_error
  has_many :memberships, dependent: :restrict_with_error
  has_many :package_purchases, dependent: :restrict_with_error
  has_many :registrations, dependent: :restrict_with_error

  validates :nickname, :password, :role, presence: true

  enum :role, { staff: 0, admin: 1 }, prefix: true

  # Delegations for easier access to member info
  delegate :name, :surname, :full_name, :email, :phone, to: :member, prefix: false
  delegate :affiliated?, to: :member

  # Validations
  validates :nickname,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscores" }
  validates :role, presence: true
  validates :member_id, presence: true, uniqueness: true

  # Custom validations
  validate :member_must_exist
  validate :cannot_discard_with_pending_transactions

  normalizes :nickname, with: -> { _1&.downcase&.strip }

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :staff_members, -> { where(role: :staff) }
  scope :active_recently, -> { where("current_sign_in_at > ?", 30.days.ago) }
  scope :by_role, ->(role) { where(role: role) }

  # Callbacks
  before_discard :check_pending_transactions

  # Instance methods
  def admin?
    role_admin?
  end

  def staff?
    role_staff?
  end

  def can_manage_users?
    admin?
  end

  def can_manage_payments?
    admin? || staff?
  end

  def can_manage_members?
    admin? || staff?
  end

  def can_view_reports?
    admin?
  end

  def has_pending_transactions?
    payments.exists? || receipts.exists? ||
      memberships.exists? || package_purchases.exists? ||
      registrations.exists?
  end

  def last_activity
    [ current_sign_in_at, last_sign_in_at ].compact.max
  end

  def active_recently?
    last_activity && last_activity > 30.days.ago
  end

  def display_name
    "#{full_name} (@#{nickname})"
  end

  # Class methods
  def self.find_by_nickname_or_email(login)
    joins(:member).where(
      "users.nickname LIKE ? OR members.email LIKE ?",
      login.downcase,
      login.downcase
    ).first
  end

  private

  def member_must_exist
    return if member_id.blank?
    return if Member.exists?(member_id)
    errors.add(:member, "must exist")
  end

  def cannot_discard_with_pending_transactions
    return unless has_pending_transactions?
    errors.add(:base, "Cannot discard user with pending transactions, payments, or receipts")
  end

  def check_pending_transactions
    if has_pending_transactions?
      errors.add(:base, "Cannot discard user with existing transactions")
      throw :abort
    end
  end
end

# TODO
# delegate :cf, :full_name, :name, :surname, "med_cert_valid?",
#          :age, :email, :phone, :birth_day, "affiliated?",
#          :med_cert_issue_date, :med_cert_exp_date, to: :user

# def active_for_authentication?
#   super && !discarded?
# end

# def email_required?
#   false
# end

# def email_changed?
#   false
# end

# def will_save_change_to_email?
#   false
# end

# def humanize_role
#   User.human_attribute_name("role.#{role}")
# end

# def self.humanize_roles
#   roles.keys.map do |key|
#     [ User.human_attribute_name("role.#{key}"), key ]
#   end
# end

# after_undiscard do
#   user&.undiscard
# end

# scope :by_name, ->(query) do
#   if query.present?
#     where(
#       "users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)",
#       q: "%#{query}%",
#       s: "%#{query.split.last}%",
#       n: "%#{query.split.first}%"
#     )
#   end
# end

# scope :by_role, ->(role) do
#   return unless role.present?

#   where(role: role.to_sym)
# end

# scope :sorted, ->(sort_by, direction) do
#   return unless %w[name surname birth_day updated_at].include?(sort_by)

#   direction = %w[asc desc].include?(direction) ? direction : "asc"
#   sort_by = sort_by == "updated_at" ? "staffs.#{sort_by}" : "users.#{sort_by}"
#   order("#{sort_by} #{direction}")
# end

# def self.filter(params)
#   case params[:visibility]
#   when "all"
#     all
#   when "deleted"
#     discarded
#   else
#     kept
#   end.joins(:user)
#     .by_name(params[:name])
#     .by_role(params[:role])
#     .sorted(params[:sort_by], params[:direction])
# end
