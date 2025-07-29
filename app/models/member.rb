# frozen_string_literal: true

# Member Model
class Member < ApplicationRecord
  include Discard::Model

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

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :surname, presence: true, length: { maximum: 100 }
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false, allow_blank: true },
            allow_blank: true
  validates :phone, phone: { possible: true, allow_blank: true, types: [ :fixed_or_mobile ] }
  validates :birth_day, presence: true
  validates :cf,
            format: { with: /\A[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]\z/ },
            uniqueness: { case_sensitive: false, allow_blank: true },
            allow_blank: true

  # Custom validations
  validate :birth_day_not_future
  validate :medical_certificate_validity
  # validate :minor_must_have_guardian # TODO

  # Scopes
  scope :affiliated, -> { where(affiliated: true) }
  scope :unaffiliated, -> { where(affiliated: false) }
  scope :with_valid_medical_cert, -> { where("med_cert_issue_date IS NOT NULL AND med_cert_issue_date > ?", 1.year.ago) }
  scope :minors, -> { where("birth_day > ?", 18.years.ago) }
  scope :adults, -> { where("birth_day <= ?", 18.years.ago) }
  scope :search_by_name, ->(query) { where("name LIKE ? OR surname LIKE ?", "%#{query}%", "%#{query}%") }

  normalizes :cf, with: -> { _1&.upcase&.strip }
  normalizes :email, with: -> { _1&.downcase&.strip }

  before_save :normalize_phone, if: -> { phone&.present? }

  after_discard :discard_associated_records
  after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor?

  # Instance methods
  def full_name
    "#{name} #{surname}"
  end

  def age
    return nil unless birth_day
    now = Time.zone.now

    age = now.year - birth_day.year
    age -= 1 if now.month < birth_day.month || (now.month == birth_day.month && now.day < birth_day.day)
    age
  end

  def minor?
    age && age < 18
  end

  def medical_certificate_valid?
    med_cert_issue_date && med_cert_issue_date > 1.year.ago
  end

  def has_active_membership?
    active_memberships.exists?
  end

  def current_membership
    active_memberships.where("start_date <= ? AND end_date >= ?", Time.zone.today, Time.zone.today).first
  end

  def can_register_for_product?(product)
    return false unless medical_certificate_valid?
    return has_active_membership? if product.requires_membership?
    true
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).national
  end

  def birth_day_not_future
    return unless birth_day
    errors.add(:birth_day, :on_or_before) if birth_day > Time.zone.today
  end

  def medical_certificate_validity
    return unless med_cert_issue_date
    errors.add(:med_cert_issue_date, :on_or_before) if med_cert_issue_date > Time.zone.today
    errors.add(:med_cert_issue_date, :expired) if med_cert_issue_date <= 2.years.ago
  end

  def minor_must_have_guardian
    return unless minor?
    errors.add(:legal_guardian, "is required for minors") unless legal_guardian_id
  end

  def discard_associated_records
    # Discard dependent records when member is discarded
    memberships.discard_all
    package_purchases.discard_all
    registrations.discard_all
    # Note: waitlists are destroyed, not discarded (they're simple join records)
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
