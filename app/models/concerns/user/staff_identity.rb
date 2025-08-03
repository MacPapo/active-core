module User::StaffIdentity
  extend ActiveSupport::Concern

  included do
    validates :nickname, presence: true, uniqueness: { case_sensitive: false }
    validates :member_id, presence: true, uniqueness: true

    normalizes :nickname, with: -> { _1&.downcase&.strip }

    scope :by_nickname, ->(query) { where("LOWER(nickname) LIKE ?", "%#{query.downcase}%") if query.present? }
  end

  def display_name
    member&.full_name || nickname.titleize
  end

  # TODO localize
  def contact_info
    member&.primary_contact || "No contact info"
  end
end
