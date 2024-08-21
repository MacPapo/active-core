# frozen_string_literal: true

# WaitList Model
class Waitlist < ApplicationRecord
  belongs_to :user
  belongs_to :activity
end
