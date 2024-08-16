class MembershipHistory < ApplicationRecord
  belongs_to :user
  belongs_to :membership
  belongs_to :staff

  enum :action, [ :creation, :renewal, :cancellation ]
end
