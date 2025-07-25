# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  include Discard::Model

  validates :name, :surname, presence: true
  validates :affiliated, inclusion: { in: [true, false] }

  validates :cf, length: { is: 16 }, allow_blank: true
  normalizes :cf, with: -> { _1.strip.upcase }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }
  validate :med_cert_issue_date_cannot_be_in_future, if: -> { med_cert_issue_date.present? }

  before_save :normalize_phone, if: -> { phone.present? }

  after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor?

  belongs_to :legal_guardian, optional: true

  has_one :staff, dependent: :destroy
  has_one :membership, dependent: :destroy

  has_many :subscriptions, dependent: :destroy
  has_many :waitlists, dependent: :destroy
  has_many :activities, through: :subscriptions

  # Payments
  has_many :payment_memberships, through: :membership, dependent: :destroy
  has_many :mpayments, through: :payment_memberships, source: :payment

  has_many :payment_subscriptions, through: :subscriptions, dependent: :destroy
  has_many :spayments, through: :payment_subscriptions, source: :payment

  def payments
    ids = mpayments.ids + spayments.ids
    Payment.where(id: ids)
  end

  # Receipts
  has_many :receipt_memberships, through: :membership, dependent: :destroy
  has_many :mreceipts, through: :receipt_memberships, source: :receipt

  has_many :receipt_subscriptions, through: :subscriptions, dependent: :destroy
  has_many :sreceipts, through: :receipt_subscriptions, source: :receipt

  def receipts
    ids = mreceipts.ids + sreceipts.ids
    Receipt.where(id: ids).order(created_at: :desc)
  end

  # After Discard
  after_discard do
    staff&.discard
    membership&.discard
    subscriptions&.discard_all
    mpayments&.discard_all
    spayments&.discard_all
    mreceipts&.discard_all
    sreceipts&.discard_all
  end

  # After Undiscard
  after_undiscard do
    staff&.undiscard
    membership&.undiscard
    subscriptions&.undiscard_all
    mpayments&.undiscard_all
    spayments&.undiscard_all
    mreceipts&.undiscard_all
    sreceipts&.undiscard_all
  end

  scope :by_name, ->(query) do
    return if query.blank?

    where(
      'users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)',
      q: "%#{query}%",
      s: "%#{query.split.last}%",
      n: "%#{query.split.first}%"
    )
  end

  scope :by_membership_status, ->(status) do
    return if status.blank?

    joins(:membership).where(membership: { status: status })
  end

  scope :by_activity_status, ->(status) do
    return if status.blank?

    joins(:subscriptions).where(subscriptions: { status: status })
  end

  scope :by_activity_id, ->(id) do
    return if id.blank?

    joins(:subscriptions).where('subscriptions.activity_id = ? AND subscriptions.discarded_at IS NULL', id.to_i)
  end

  scope :sorted, ->(sort_by, direction) do
    return unless %w[name surname birth_day updated_at].include?(sort_by)

    order("users.#{sort_by} #{direction}")
  end

  def self.filter(params)
    case params[:visibility]
    when 'all'
      all
    when 'deleted'
      discarded
    else
      kept
    end
      .by_name(params[:name])
      .by_membership_status(params[:membership_status])
      .by_activity_status(params[:activity_status])
      .by_activity_id(params[:activity_id])
      .sorted(params[:sort_by], params[:direction] || 'desc')
  end

  def sfilter(params)
    case params[:visibility]
    when 'all'
      subscriptions.all
    when 'deleted'
      subscriptions.discarded
    else
      subscriptions.kept
    end
      .by_activity_name(params[:name])
      .by_activity_id(params[:activity_id])
      .by_open(params[:open])
    #.sorted(params[:sort_by], params[:direction] || 'desc')
  end

  def pfilter(params)
    case params[:visibility]
    when 'all'
      payments.all
    when 'deleted'
      payments.discarded
    else
      payments.kept
    end
      .joins(:staff)
      .includes(:staff, :payment_membership, :payment_subscription)
      .by_created_at(params[:from], params[:to])
      .by_name(params[:name])
      .by_type(params[:type])
      .by_method(params[:method])
      .sorted(params[:sort_by], params[:direction])
  end

  def full_name
    "#{name} #{surname}"
  end

  def minor?
    birth_day && age.years < 18.years
  end

  def affiliated?
    affiliated
  end

  def age
    ((Time.zone.now - birth_day.to_time) / 1.year.seconds).floor
  end

  def med_cert_exp_date
    med_cert_issue_date.present? ? med_cert_issue_date + 1.year : nil
  end

  def num_of_days_til_med_cert_expire
    return -1 if med_cert_issue_date.nil?

    exp_date = med_cert_issue_date + 1.year
    (exp_date - Time.zone.today).to_i
  end

  def active_membership?
    membership&.active?
  end

  def has_payments?
    !spayments&.empty? || !mpayments&.empty?
  end

  def verify_compliance
    avoid = %w[id cf affiliated legal_guardian_id created_at updated_at discarded_at]
    avoid_minor = %w[email phone]

    attribute_names.map do |x|
      next if avoid.include?(x)

      val = send(x)
      next if avoid_minor.include?(x) && minor?

      next if val.present?

      User.human_attribute_name(x)
    end.compact
  end

  def med_cert_valid?
    return false if med_cert_issue_date.blank?

    Time.zone.today < med_cert_issue_date + 1.year
  end

  def has_open_subscription?
    return false if subscriptions.blank?

    subscriptions.each { |x| return true if x.open? }

    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).national
  end

  def med_cert_issue_date_cannot_be_in_future
    return unless med_cert_issue_date > Time.zone.today

    errors.add(:med_cert_issue_date, I18n.t('global.errors.med_date_future'))
  end
end
