# frozen_string_literal: true

# Activity Model
class Activity < ApplicationRecord
  include Discard::Model

  has_many :users, through: :subscriptions
  has_many :subscriptions, dependent: :destroy
  has_many :waitlists, dependent: :destroy
  has_many :activity_plans, dependent: :destroy

  normalizes :name, with: -> { _1.capitalize }

  validates :name, presence: true, uniqueness: true
  validates :num_participants, presence: true
  validates :num_participants, numericality: { greater_than: 0 }

  # After Discard
  after_discard do
    subscriptions&.discard_all
    activity_plans&.discard_all
    waitlists&.destroy_all
  end

  # After Undiscard
  after_undiscard do
    subscriptions&.undiscard_all
    activity_plans&.undiscard_all
  end

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  scope :by_range, lambda { |range|
    return unless range.present? && range.to_i.positive?

    joins(:subscriptions).group(:activity_id).having("COUNT(*) = ?", range.to_i)
  }

  scope :by_max_num, lambda { |num|
    return unless num.present? && num.to_i.positive?

    where(num_participants: num.to_i)
  }

  scope :sorted, lambda { |sort_by, direction|
    return unless %w[name num_participants updated_at].include?(sort_by)

    direction = %w[asc desc].include?(direction) ? direction : "asc"
    order("activities.#{sort_by} #{direction}")
  }

  scope :order_by_updated_at, -> { order("updated_at desc") }

  def self.filter(params)
    case params[:visibility]
    when "all"
      all
    when "deleted"
      discarded
    else
      kept
    end.by_name(params[:name])
      .by_range(params[:range])
      .by_max_num(params[:number])
      .sorted(params[:sort_by], params[:direction])
  end

  def pfilter(params)
    case params[:visibility]
    when "all"
      activity_plans.all
    when "deleted"
      activity_plans.discarded
    else
      activity_plans.kept
    end.by_cost
  end
end
