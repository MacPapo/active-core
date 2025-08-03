# frozen_string_literal: true

# Member Model
class Member < ApplicationRecord
  include Discard::Model
  include Member::RevenueTracking
  include Member::PersonalIdentity, Member::Contactable, Member::MedicalCertification
  include Membership::Business, Membership::Lifecycle

  # Associations
  belongs_to :legal_guardian, optional: true
  has_one :user, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :package_purchases, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :waitlists, dependent: :destroy

  # Through associations for easier querying
  has_many :active_memberships, -> { where(status: :active) }, class_name: "Membership"
  has_many :active_registrations, -> { where(status: :active) }, class_name: "Registration"
  has_many :products, through: :registrations
  has_many :packages, through: :package_purchases

  # Scopes
  scope :affiliated, -> { where(affiliated: true) }
  scope :unaffiliated, -> { where(affiliated: false) }

  normalizes :cf, with: -> { _1&.upcase&.strip }
  normalizes :email, with: -> { _1&.downcase&.strip }

  after_discard :discard_associated_records
  # after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor? TODO

  private

  def discard_associated_records
    memberships.discard_all
    package_purchases.discard_all
    registrations.discard_all
    waitlists.destroy_all
  end
end

# TODO
# scope :by_name, ->(query) do
#   return if query.blank?

#   where(
#     "users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)",
#     q: "%#{query}%",
#     s: "%#{query.split.last}%",
#     n: "%#{query.split.first}%"
#   )
# end

# scope :by_membership_status, ->(status) do
#   return if status.blank?

#   joins(:membership).where(membership: { status: status })
# end

# scope :by_activity_status, ->(status) do
#   return if status.blank?

#   joins(:subscriptions).where(subscriptions: { status: status })
# end

# scope :by_activity_id, ->(id) do
#   return if id.blank?

#   joins(:subscriptions).where("subscriptions.activity_id = ? AND subscriptions.discarded_at IS NULL", id.to_i)
# end

# scope :sorted, ->(sort_by, direction) do
#   return unless %w[name surname birth_day updated_at].include?(sort_by)

#   order("users.#{sort_by} #{direction}")
# end

# def self.filter(params)
#   case params[:visibility]
#   when "all"
#     all
#   when "deleted"
#     discarded
#   else
#     kept
#   end
#     .by_name(params[:name])
#     .by_membership_status(params[:membership_status])
#     .by_activity_status(params[:activity_status])
#     .by_activity_id(params[:activity_id])
#     .sorted(params[:sort_by], params[:direction] || "desc")
# end

# def sfilter(params)
#   case params[:visibility]
#   when "all"
#     subscriptions.all
#   when "deleted"
#     subscriptions.discarded
#   else
#     subscriptions.kept
#   end
#     .by_activity_name(params[:name])
#     .by_activity_id(params[:activity_id])
#     .by_open(params[:open])
#   # .sorted(params[:sort_by], params[:direction] || 'desc')
# end

# def pfilter(params)
#   case params[:visibility]
#   when "all"
#     payments.all
#   when "deleted"
#     payments.discarded
#   else
#     payments.kept
#   end
#     .joins(:staff)
#     .includes(:staff, :payment_membership, :payment_subscription)
#     .by_created_at(params[:from], params[:to])
#     .by_name(params[:name])
#     .by_type(params[:type])
#     .by_method(params[:method])
#     .sorted(params[:sort_by], params[:direction])
# end
