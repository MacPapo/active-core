class ActivityPlan < ApplicationRecord
  belongs_to :activity

  enum plan: [
         :one_entrance,
         :half_month,
         :one_month,
         :three_months,
         :one_year,
         :one_month_one_lesson,
         :one_month_two_lessons
       ]

  validates :activity, presence: true
  validates :plan, presence: true
  validates :cost, numericality: { greater_than: 0 }
end
