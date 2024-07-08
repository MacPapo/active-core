require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { create(:user) }
  let(:subscription_type) { create(:subscription_type) }
  let(:course) { create(:course) }

  it 'should be valid with all attributes' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course
    )
    expect(sub).to be_valid
  end

  it 'should be valid without start_date & end_date' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course,
      start_date: nil,
      end_date: nil
    )
    expect(sub).to be_valid
  end

  it 'should be invalid with start_date but without end_date' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course,
      start_date: '2024-01-01',
      end_date: nil
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid with end_date but without start_date' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course,
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
      course: course
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid without subscription_type attribute' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: nil,
      course: course
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid without course attribute' do
    sub = build(
      :subscription,
      user: user,
      subscription_type: nil,
      course: course
    )
    expect(sub).to be_invalid
  end

  it 'should be invalid if start_date > end_date' do
    sub1 = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course,
      start_date: '2024-01-02',
      end_date: '2024-01-01'
    )
    expect(sub1).to be_invalid

    sub2 = build(
      :subscription,
      user: user,
      subscription_type: subscription_type,
      course: course,
      start_date: '2024-01-02',
      end_date: '2024-01-02'
    )
    expect(sub2).to be_invalid
  end
end
