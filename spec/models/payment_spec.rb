require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }
  let(:activity) { create(:activity) }
  let(:activity_plan) { create(:activity_plan, activity: activity) }
  let(:membership) { create(:membership, user: user, staff: staff) }
  let(:subscription) { create(:subscription, user: user, staff: staff, activity: activity, activity_plan: activity_plan) }

  before do
    user.create_membership(staff: staff, start_date: '2024-01-01')
    payment = create(:payment, staff: staff, payable: user.membership)
    user.reload_membership
  end

  it 'is valid with valid attributes' do
    payment_1 = build(:payment, staff: staff, payable: subscription)
    payment_2 = build(:payment, staff: staff, payable: membership)
    expect(payment_1).to be_valid
    expect(payment_2).to be_valid

    expect(payment_2.amount).to eq(35.0)
  end

  it 'is valid without amount, amount selected automagically' do
    payment_1 = build(:payment, amount: nil, staff: staff, payable: subscription)
    payment_2 = build(:payment, amount: nil, staff: staff, payable: membership)
    expect(payment_1).to be_valid
    expect(payment_2).to be_valid

    expect(payment_2.amount).to eq(35.0)
  end

  it 'is valid without date, date added automagically' do
    payment_1 = build(:payment, date: nil, staff: staff, payable: subscription)
    payment_2 = build(:payment, date: nil, staff: staff, payable: membership)
    expect(payment_1).to be_valid
    expect(payment_2).to be_valid
  end

  it 'is invalid without payment_method' do
    payment_1 = build(:payment, payment_method: nil, staff: staff, payable: subscription)
    payment_2 = build(:payment, payment_method: nil, staff: staff, payable: membership)
    expect(payment_1).not_to be_valid
    expect(payment_2).not_to be_valid
  end

  it 'is invalid without payment_type' do
    payment = build(:payment, payable: nil, staff: staff)
    expect(payment).not_to be_valid
  end

  it 'is invalid without entry_type' do
    payment_1 = build(:payment, entry_type: nil, staff: staff, payable: subscription)
    payment_2 = build(:payment, entry_type: nil, staff: staff, payable: membership)
    expect(payment_1).not_to be_valid
    expect(payment_2).not_to be_valid
  end
end
