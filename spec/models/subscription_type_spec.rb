require 'rails_helper'

RSpec.describe SubscriptionType, type: :model do
  it 'should be valid with all attributes' do
    type = build(:subscription_type)
    expect(type).to be_valid
  end

  it 'should be invalid without plan' do
    type = build(:subscription_type, plan: nil)
    expect(type).to be_invalid
  end

  it 'should be valid without plan' do
    type = build(:subscription_type, desc: nil)
    expect(type).to be_valid
  end

  it 'should be invalid without duration' do
    type = build(:subscription_type, duration: nil)
    expect(type).to be_invalid
  end

  it 'should be invalid without cost' do
    type = build(:subscription_type, cost: nil)
    expect(type).to be_invalid
  end

  it 'should be invalid if duration > 365 days' do
    [
      366..500
    ].each do |dur|
      type = build(:subscription_type, duration: dur)
      expect(type).to be_invalid
    end
  end

  it 'should be invalid if duration < 15 days' do
    (1...15).each do |dur|
      type = build(:subscription_type, duration: dur)
      expect(type).to be_invalid
    end
  end

  it 'should be invalid if costs < 0' do
    (-10...0).each do |cost|
      type = build(:subscription_type, cost: cost)
      expect(type).to be_invalid
    end
  end
end
