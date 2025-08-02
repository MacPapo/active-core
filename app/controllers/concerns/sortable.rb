module Sortable
  extend ActiveSupport::Concern

  private

  def apply_sorting(scope)
    sort_attribute = params[:sort_by] || default_sort[:attribute]
    sort_direction = params[:direction] || default_sort[:direction]

    return scope unless sortable_attributes.key?(sort_attribute)

    column = sortable_attributes[sort_attribute]
    scope.order("#{column} #{sort_direction}")
  end

  def sortable_attributes
    {}
  end

  def default_sort
    { attribute: "created_at", direction: "desc" }
  end
end
