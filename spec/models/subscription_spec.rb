require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }
  let(:subscription_type) { create(:subscription_type) }
  let(:subscription_type_quota) { create(:subscription_type, plan: :quota, desc: 'Quota Associativa', duration: 365, cost: 35) }
  let(:activity) { create(:activity) }

  before do
    user.subscriptions.create!(
      start_date: Date.today,
      subscription_type: subscription_type_quota,
      staff: staff,
      state: :attivo
    )
  end

  it 'allows activity subscription with annual membership' do
    activity_subscription = user.subscriptions.build(
      start_date: Date.today,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity
    )

    expect(activity_subscription).to be_valid
  end

  it 'does not allow activity subscription without annual membership' do
    user.subscriptions.destroy_all

    activity_subscription = user.subscriptions.build(
      start_date: Date.today,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity
    )

    expect(activity_subscription).not_to be_valid
    expect(activity_subscription.errors[:base]).to include("You must have an active annual membership to enroll in a activity.")
  end

  it 'should be valid with all attributes' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_valid
  end

  it 'should be invalid without start_date & end_date' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity,
      start_date: nil,
      end_date: nil
    )
    expect(sub).to be_invalid
  end

  it 'should be valid with start_date but without end_date, end_date update automagically' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity,
      start_date: '2024-01-01',
      end_date: nil
    )
    expect(sub).to be_valid
  end

  it 'should be invalid with end_date but without start_date' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity,
      start_date: nil,
      end_date: '2024-01-01'
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid without user attribute' do
    sub = build(
      :subscription,
      user: nil,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity
    )
    expect(sub).not_to be_valid
  end

  it 'should be invalid without subscription_type attribute' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: nil,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid without activity attribute' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: nil,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_invalid
  end

  it 'should be valid if start_date > end_date, end_date update automagically' do
    sub1 = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity,
      start_date: '2024-01-02',
      end_date: '2024-01-01'
    )
    expect(sub1).to be_valid

    sub2 = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      staff: staff,
      activity: activity,
      start_date: '2024-01-02',
      end_date: '2024-01-02'
    )
    expect(sub2).to be_valid
  end
end
