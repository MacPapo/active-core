class MembershipHistory < ApplicationRecord
  belongs_to :membership
  belongs_to :user
  belongs_to :staff

  enum action: [:creazione, :rinnovo, :cancellazione]
end
