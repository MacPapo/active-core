module Product::CapacityManagement
  extend ActiveSupport::Concern

  included do
    validates :capacity, comparison: { greater_than: 0 }, allow_blank: true

    scope :full, -> {
      joins(:registrations)
        .where(registrations: { status: :active })
        .group(:id)
        .having("COUNT(registrations.id) >= products.capacity")
        .where.not(capacity: nil)
    }
    scope :available, -> { where.not(id: full.select(:id)) }
  end

  def current_registrations_count
    registrations.active.count
  end

  def available_spots
    return Float::INFINITY if unlimited_capacity?
    [ capacity - current_registrations_count, 0 ].max
  end

  def full?
    return false if unlimited_capacity?
    current_registrations_count >= capacity
  end

  def has_available_spots?
    !full?
  end

  def utilization_percentage
    return 0 if unlimited_capacity?
    (current_registrations_count.to_f / capacity * 100).round(1)
  end
end
