require 'rails_helper'

RSpec.describe Membership, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }

  it 'should be valid with all attributes' do
    mem = build(:membership, user: user, staff: staff)
    expect(mem).to be_valid
  end

  it 'should be invalid without user and staff attribute' do
    mem = build(:membership, user: nil, staff: nil)
    expect(mem).not_to be_valid
  end

  it 'should be invalid without user attribute' do
    mem = build(:membership, user: nil, staff: staff)
    expect(mem).not_to be_valid
  end

  it 'should be invalid without staff attribute' do
    mem = build(:membership, user: user, staff: nil)
    expect(mem).not_to be_valid
  end

  it 'should have 35.0 as price' do
    mem = build(:membership, user: user, staff: staff)
    expect(mem.cost).to eq(35.0)
  end
end
