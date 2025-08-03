module Member::PersonalIdentity
  extend ActiveSupport::Concern

  included do
    validates :name, :surname, presence: true, length: { in: 1..100 }
    validates :birth_day, presence: true,
              comparison: { less_than_or_equal_to: -> { Date.current } }

    validates :cf, format: {
      with: /\A[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]\z/,
      allow_blank: true
    }, uniqueness: { case_sensitive: false, allow_blank: true }

    normalizes :cf, with: -> { _1&.upcase&.strip }
    normalizes :name, :surname, with: -> { _1&.titleize&.strip }

    scope :minors, -> { where(birth_day: 18.years.ago..) }
    scope :adults, -> { where(birth_day: ..18.years.ago) }
    scope :born_after, ->(date) { where(birth_day: date..) }
    scope :search_by_name, ->(query) {
      where("name LIKE :q OR surname LIKE :q OR CONCAT(name, ' ', surname) LIKE :q",
            q: "%#{query}%") if query.present?
    }
  end

  def full_name = "#{name} #{surname}"

  def age
    return unless birth_day
    (Date.current - birth_day).to_i / 365
  end

  def minor? = age && age < 18
  def adult? = !minor?
end
