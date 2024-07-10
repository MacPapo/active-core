require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }
  let(:activity) { create(:activity) }
  let(:activity_plan) { create(:activity_plan, activity: activity) }

  it 'allows activity subscription with annual membership' do
    activity_subscription = user.subscriptions.build(
      start_date: Date.today,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity
    )

    expect(activity_subscription).to be_valid
  end

  it 'does not allow activity subscription without annual membership' do
    user.subscriptions.destroy_all

    activity_subscription = user.subscriptions.build(
      start_date: Date.today,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity
    )

    expect(activity_subscription).not_to be_valid
  end

  it 'should be valid with all attributes' do
    sub = build(
      :subscription,
      user: user,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_valid
  end

  it 'should be invalid without start_date & end_date' do
    sub = build(
      :subscription,
      user: user,
      activity_plan: activity_plan,
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
      activity_plan: activity_plan,
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
      activity_plan: activity_plan,
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
      activity_plan: activity_plan,
      staff: staff,
      activity: activity
    )
    expect(sub).not_to be_valid
  end

  it 'should be invalid without activity_plan attribute' do
    sub = build(
      :subscription,
      user: user,
      activity_plan: nil,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid without activity attribute' do
    sub = build(
      :subscription,
      user: user,
      activity_plan: nil,
      staff: staff,
      activity: activity
    )
    expect(sub).to be_invalid
  end

  it 'should be valid if start_date > end_date, end_date update automagically' do
    sub1 = build(
      :subscription,
      user: user,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity,
      start_date: '2024-01-02',
      end_date: '2024-01-01'
    )
    expect(sub1).to be_valid

    sub2 = build(
      :subscription,
      user: user,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity,
      start_date: '2024-01-02',
      end_date: '2024-01-02'
    )
    expect(sub2).to be_valid
  end
end
