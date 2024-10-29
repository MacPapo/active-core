# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  include Discard::Model

  belongs_to :staff

  has_one :payment_membership, dependent: :destroy
  has_one :payment_subscription, dependent: :destroy
  has_one :receipt, dependent: :destroy

  has_one :muser, through: :payment_membership, source: :user
  has_one :suser, through: :payment_subscription, source: :user

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  after_discard do
    payment_membership&.discard
    payment_subscription&.discard
    receipt&.discard
  end

  after_undiscard do
    payment_membership&.undiscard
    payment_subscription&.undiscard
    receipt&.undiscard
  end

  enum :method, { cash: 0, pos: 1, bank_transfer: 2, voucher: 3 }, default: :cash

  scope :by_visibility, ->(visibility) do
    return if visibility.blank?

    case visibility
    when 'all'
      all
    when 'deleted'
      discarded
    else
      kept
    end
  end

  scope :by_created_at, ->(from, to) do
    return if from.blank? && to.blank?

    if from.blank?
      end_date = DateTime.parse(to).end_of_day
      where('payments.created_at': ..end_date)
    elsif to.blank?
      where('payments.created_at': from..)
    else
      end_date = to.is_a?(String) ? DateTime.parse(to).end_of_day : to
      where('payments.created_at': from..end_date)
    end
  end

  scope :by_name, ->(query) do
    return if query.blank?

    where('staffs.nickname LIKE :q OR payments.note LIKE :q', q: "%#{query}%")
  end

  scope :by_type, ->(type) do
    return if type.blank?

    case type
    when 'mem'
      joins(:payment_membership)
    when 'sub'
      joins(:payment_subscription)
    else
      left_joins(:payment_membership, :payment_subscription)
    end
  end

  scope :by_method, ->(method) do
    return if method.blank?

    where('payments.method': method) if method.present?
  end

  scope :sorted, ->(sort_by, direction) do
    return unless %w[created_at date amount staff updated_at].include?(sort_by)

    sort_by = sort_by == 'staff' ? 'staffs.nickname' : "payments.#{sort_by}"
    order("#{sort_by} #{direction}")
  end

  def self.filter(params)
    by_visibility(params[:visibility])
      .joins(:staff)
      .by_name(params[:name])
      .by_type(params[:type])
      .by_method(params[:method])
      .by_created_at(params[:from], params[:to])
      .sorted(params[:sort_by], params[:direction])
  end

  def self.daily_cash(period, params)
    return if period.blank? || params.blank?

    mid = Time.zone.now.beginning_of_day
    select_range = ->(y) { kept.by_created_at(mid + y.first, mid + y.last).sorted(params[:sort_by], params[:direction]) }

    select_range.call(period == :morning ? [7.hours, 14.hours] : [14.hours, 21.hours])
  end

  def self.humanize_payment_methods
    methods.keys.map { |key| [Payment.human_attribute_name("method.#{key}"), key] }
  end

  def humanize_payment_method(method = self.method)
    Payment.human_attribute_name("method.#{method}")
  end

  def humanize_payable_type
    mem = payment_membership
    sub = payment_subscription

    return unless mem.present? || sub.present?

    type = mem.present? ? 'membership' : 'subscription'

    Payment.human_attribute_name("payable.#{type}")
  end

  def amount_to_currency
    ActionController::Base.helpers.number_to_currency amount
  end
end
