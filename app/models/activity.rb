# frozen_string_literal: true

# Activity Model
class Activity < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :waitlists, dependent: :destroy
  has_many :activity_plans, dependent: :destroy

  normalizes :name, with: -> { _1.capitalize }

  validates :name, presence: true, uniqueness: true
  validates :num_participants, presence: true
  validates :num_participants, numericality: { greater_than: 0 }

  scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") if name.present? }
  scope :sorted, ->(sort_by, direction) do
    if %w[name num_participants].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : 'asc'
      order("#{sort_by} #{direction}")
    end
  end

  scope :order_by_updated_at, -> { order('updated_at desc') }

  def self.filter(name, sort_by, direction)
    by_name(name)
      .sorted(sort_by, direction)
      .order_by_updated_at
  end
end
