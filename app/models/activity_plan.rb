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

  def get_plan
    self.plan.to_sym
  end

  def humanize_plan
    case self.plan
    when "one_entrance"
      "1 Entrata"
    when "half_month"
      "1/2 Mese"
    when "one_month"
      "1 Mese"
    when "three_month"
      "3 Mesi"
    when "one_year"
      "1 Anno"
    when "one_month_one_lesson"
      "1 Mese, 1 volta a settimana"
    when "one_month_two_lessons"
      "1 Mese, 2 volte a settimana"
    else
      "Non definito"
    end
  end
end
