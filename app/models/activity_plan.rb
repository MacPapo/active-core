class ActivityPlan < ApplicationRecord
  belongs_to :activity

  enum :plan, [
         :one_entrance,
         :half_month,
         :one_month,
         :three_months,
         :one_year,
         :one_month_one_lesson,
         :one_month_two_lessons
       ], default: :one_month

  validates :activity, presence: true
  validates :plan, presence: true
  validates :cost, numericality: { greater_than: 0 }

  def get_plan
    self.plan.to_sym
  end

  def self.humanize_plans(keys=plans.keys)
    keys.map do |key|
      [I18n.t("activemodel.enums.activity_plan.plan.#{key}"), key]
    end
  end

  def humanize_plan
    I18n.t("activemodel.enums.activity_plan.plan.#{self.plan}")
  end
end
