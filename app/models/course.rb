class Course < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
end
