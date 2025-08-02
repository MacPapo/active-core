module Filterable
  extend ActiveSupport::Concern

  private

  def apply_filters(scope)
    filterable_attributes.each do |param, filter_proc|
      scope = filter_proc.call(scope, params[param]) if params[param].present?
    end
    scope
  end

  def filterable_attributes
    {}
  end
end
