module Product::Catalog
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true, length: { in: 1..200 }
    validates :product_type, presence: true
    validates :description, length: { maximum: 1000 }, allow_blank: true
    validates :capacity, comparison: { greater_than: 0 }, allow_blank: true

    validates :name, uniqueness: {
                scope: :product_type,
                case_sensitive: false,
                conditions: -> { where(discarded_at: nil) }
              }

    normalizes :name, with: -> { _1&.titleize&.strip }
    normalizes :product_type, with: -> { _1&.downcase&.strip }

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
    scope :by_type, ->(type) { where(product_type: type) if type.present? }
    scope :with_capacity, -> { where.not(capacity: nil) }
    scope :unlimited_capacity, -> { where(capacity: nil) }
    scope :search_by_name, ->(query) {
      where("name LIKE ?", "%#{query}%") if query.present?
    }
  end

  def active?
    active
  end

  def has_capacity_limit?
    capacity.present?
  end

  def unlimited_capacity?
    !has_capacity_limit?
  end

  def display_name
    "#{name} (#{product_type.humanize})"
  end
end
