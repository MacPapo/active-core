class User < ApplicationRecord
  belongs_to :legal_guardian, optional: true
  has_one :staff, dependent: :destroy

  validates :name, :surname, :date_of_birth, presence: true
  validate :legal_guardian_presence_for_minors

  def full_name
    "#{self.name} #{self.surname}"
  end

  def minor?
    date_of_birth > 18.year.ago.to_date
  end

  private

  def legal_guardian_presence_for_minors
    if minor? && legal_guardian.nil?
      errors.add(:legal_guardian, "must be present for minors")
    end
  end
end
