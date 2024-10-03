# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  validates :payment_method, :entry_type, :payable, :staff, presence: true

  after_save :activate_membership_or_subscription

  belongs_to :payable, polymorphic: true
  belongs_to :staff

  has_one :receipt, dependent: :destroy

  enum :payment_method, { pos: 0, cash: 1, bank_transfer: 2 }, default: :cash
  enum :entry_type, { income: 0, expense: 1 }, default: :income

  scope :by_interval, ->(from, to) do
    return if from.blank? && to.blank?

    if from.present? && to.present?
      where('payments.date': from..to)
    elsif from.present?
      where('payments.date >= ?', from)
    else
      where('payments.date <= ?', to)
    end
  end

  scope :by_created_at, ->(from, to) { where(created_at: from..to).order(created_at: :desc) }
  scope :by_name, ->(query) { where('staffs.nickname LIKE :q OR payments.note LIKE :q', q: "%#{query}%") }
  scope :by_type, ->(type) { where(payable_type: type.capitalize) if type.present? }
  scope :by_method, ->(method) { where(payment_method: method) if method.present? }

  scope :sorted, ->(sort_by, direction) do
    return unless %w[date amount staff updated_at].include?(sort_by)

    sort_by = sort_by == 'staff' ? 'staffs.nickname' : "payments.#{sort_by}"
    order("#{sort_by} #{direction}")
  end

  def self.filter(params)
    joins(:staff)
      .by_name(params[:name])
      .by_type(params[:type])
      .by_method(params[:method])
      .by_interval(params[:from], params[:to])
      .sorted(params[:sort_by], params[:direction])
  end

  def self.daily_cash(arg)
    return nil if arg.blank?

    mid = Time.zone.now.beginning_of_day
    select_range = ->(y) { by_created_at(mid + y.first, mid + y.last) }

    select_range.call(arg == :morning ? [7.hours, 14.hours] : [14.hours, 21.hours])
  end

  def payment_summary
    payable.summary
  end

  def user
    payable&.user
  end

  def humanize_payable_type(type = payable_type)
    Payment.human_attribute_name("payable.#{type.downcase}")
  end

  def humanize_payment_method(method = payment_method)
    Payment.human_attribute_name("method.#{method}")
  end

  def humanize_entry_type(type = entry_type)
    Payment.human_attribute_name("type.#{type}")
  end

  def self.humanize_payable_types
    Payment
      .select(:payable_type)
      .distinct
      .pluck(:payable_type).map { |x| [Payment.human_attribute_name("payable.#{x.downcase}"), x] }
  end

  def self.humanize_payment_methods
    payment_methods.keys.map { |key| [Payment.human_attribute_name("method.#{key}"), key] }
  end

  def self.humanize_entry_types
    entry_types.keys.map { |key| [Payment.human_attribute_name("type.#{key}"), key] }
  end

  private

  def set_default_date
    self.date ||= Time.zone.today
  end

  # TODO undo activation if payment is destroyed
  def activate_membership_or_subscription
    ActivateThingJob.perform_later(payable_type, payable_id)
  end
end
