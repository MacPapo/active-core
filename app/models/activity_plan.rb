# frozen_string_literal: true

# ActivityPlan Model
class ActivityPlan < ApplicationRecord
  belongs_to :activity

  enum :plan, { one_entrance: 0,
                half_month: 1,
                one_month: 2,
                one_month_one_lesson: 3,
                one_month_two_lessons: 4,
                three_months: 5,
                one_year: 6 }, default: :one_month

  validates :activity, presence: true
  validates :plan, presence: true
  validates :cost, numericality: { greater_than: 0 }

  # TODO delete me
  def get_plan
    self.plan.to_sym
  end

  def self.humanize_plans(keys = plans.keys)
    keys.map do |key|
      [ActivityPlan.human_attribute_name("plan.#{key}"), key]
    end
  end

  def humanize_plan
    ActivityPlan.human_attribute_name("plan.#{plan}")
  end
end
