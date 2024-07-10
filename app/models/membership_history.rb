class MembershipHistory < ApplicationRecord
  belongs_to :membership
  belongs_to :user
  belongs_to :staff

  enum action: [:creazione, :rinnovo, :cancellazione]
  after_initialize :set_default_action, :if => :new_record?
  def set_default_action
    self.action ||= :creazione
  end

  validates :start_date, :end_date, :action, presence: true
end
