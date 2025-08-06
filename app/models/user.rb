# frozen_string_literal: true

# User Model
# app/models/user.rb

class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :timeoutable, :trackable,
         authentication_keys: [ :nickname ]

  belongs_to :member

  has_many :access_grants, dependent: :nullify
  has_many :payments, dependent: :nullify

  delegate :first_name, :last_name, :full_name, :birth_date, :age,
           :phone, :email, to: :member, allow_nil: true

  enum role: {
         staff: 0,
         admin: 1
       }

  validates :nickname, presence: true, uniqueness: true
  validates :member_id, presence: true, uniqueness: true
  validates :role, presence: true

  normalize :nickname, with: -> { _1&.downcase&.strip }
end
