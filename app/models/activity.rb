# frozen_string_literal: true

# Activity Model
class Activity < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :waitlists, dependent: :destroy
  has_many :activity_plans, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :num_participants, presence: true
  validates :num_participants, numericality: { greater_than: 0 }

  scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") if name.present? }
  scope :order_by_num_participants, ->(num) { order("num_participants #{num&.upcase}") }
  scope :order_by_updated_at, ->(direction) { order("updated_at #{direction.blank? ? 'DESC' : direction&.upcase}") }

  def self.filter(name, num, direction)
    by_name(name).order_by_num_participants(num).order_by_updated_at(direction)
  end
end
