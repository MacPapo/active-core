# frozen_string_literal: true

# Waitlist Model
class Waitlist < ApplicationRecord
  belongs_to :member
  belongs_to :product

  validates :member_id, uniqueness: { scope: :product_id,
                                      message: "is already on waitlist for this product" }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :for_product, ->(product) { where(product: product) }
  scope :for_member, ->(member) { where(member: member) }
  scope :by_priority, -> { order(:priority, :created_at) }
  scope :high_priority, -> { where(priority: 1..) }
  scope :standard_priority, -> { where(priority: 0) }

  before_validation :set_default_priority, on: :create

  def position_in_queue
    self.class.where(product: product)
      .where("priority > ? OR (priority = ? AND created_at < ?)",
        priority, priority, created_at)
      .count + 1
  end

  def next_in_line?
    position_in_queue == 1
  end

  def estimated_wait_time
    return "Available now" if product.has_capacity?

    position = position_in_queue
    case position
    when 1 then "Next available"
    when 2..5 then "#{position} weeks estimated"
    else "#{position} weeks+ estimated"
    end
  end

  def self.notify_next_available(product)
    next_waitlist = for_product(product).by_priority.first
    return unless next_waitlist

    # Could trigger notification job here
    # WaitlistNotificationJob.perform_later(next_waitlist)
    next_waitlist
  end

  private

  def set_default_priority
    self.priority ||= 0
  end
end
