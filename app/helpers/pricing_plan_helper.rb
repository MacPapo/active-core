module PricingPlanHelper
  def duration_type_options
    PricingPlan.duration_types.map do |key, value|
      [ key.humanize, key ]
    end
  end
end
