# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  include Discard::Model
  include User::StaffIdentity, User::RoleManagement, User::ActivityTracking, User::AuthenticationTracking

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :omniauthable
  devise :database_authenticatable, :timeoutable, :trackable, authentication_keys: [ :nickname ]

  # Associations
  belongs_to :member
  has_many :memberships, dependent: :destroy
  has_many :package_purchases, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :receipts, dependent: :destroy

  delegate :full_name, :email, :phone, :affiliated?, to: :member, allow_nil: true

  after_discard :discard_associated_records

  def active_for_authentication?
    super && !discarded?
  end

  private

  def discard_associated_records
    # Keep financial records, just discard operational ones
    memberships.discard_all
    package_purchases.discard_all
    registrations.discard_all
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
