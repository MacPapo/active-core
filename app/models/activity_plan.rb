# frozen_string_literal: true

# ActivityPlan Model
class ActivityPlan < ApplicationRecord
  belongs_to :activity

  enum :plan, %i[one_entrance half_month one_month
                 one_month_one_lesson one_month_two_lessons
                 three_months one_year ], default: :one_month

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
