module StaffIdentity
  extend ActiveSupport::Concern

  included do
    validates :nickname, presence: true, uniqueness: { case_sensitive: false }
    validates :member_id, presence: true, uniqueness: true

    normalizes :nickname, with: -> { _1&.downcase&.strip }

    scope :by_nickname, ->(query) {
      where("nickname LIKE ?", "%#{query}%") if query.present?
    }
  end

  def display_name
    member&.full_name || nickname.titleize
  end

  def staff_member?
    member.present?
  end

  def contact_info
    member&.primary_contact || "No contact info"
  end
end
