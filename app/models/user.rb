class User < ApplicationRecord
  belongs_to :legal_guardian, optional: true
end
