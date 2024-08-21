# frozen_string_literal: true

# Membership History Model
class MembershipHistory < ApplicationRecord
  belongs_to :user
  belongs_to :membership
  belongs_to :staff

  enum :action, %i[creation renewal cancellation]
end
