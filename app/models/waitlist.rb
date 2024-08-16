# frozen_string_literal: true

class Waitlist < ApplicationRecord
  belongs_to :user
  belongs_to :activity
end
