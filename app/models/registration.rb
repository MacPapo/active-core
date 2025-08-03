# frozen_string_literal: true

# Registration Model
class Registration < ApplicationRecord
  include Discard::Model

  include ServiceLifecycle
  include Terminable
  include Course::Access
  include Package::Integration
  include Financial::BillingManagement
  include Registration::Analytics, Registration::SessionManagement

  # Associations
  belongs_to :user
  belongs_to :member
  belongs_to :product
  belongs_to :pricing_plan
  belongs_to :package, optional: true

  # Callbacks
  after_create :sync_with_package_purchase!
  after_update :handle_status_changes
  before_destroy :return_sessions_to_package

  # Business logic scopes
  scope :instructor_registrations, ->(user) { where(user: user) }
  scope :needs_attention, -> {
    where(status: :active)
      .where("(sessions_remaining IS NOT NULL AND sessions_remaining <= 2) OR end_date <= ?", 1.week.from_now)
  }

  def display_name
    "#{member.full_name} - #{product.name}"
  end

  private

  def handle_status_changes
    return unless saved_change_to_status?

    if became_expired?
      # Handle expiration logic
      package&.handle_registration_expiry(self) if from_package?
    end
  end

  def became_expired?
    saved_change_to_status? && status == "expired"
  end

  # TODO
  def return_sessions_to_package
    # Complex package session return logic if needed
  end
end
