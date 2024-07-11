require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }
  let(:activity) { create(:activity) }
  let(:activity_plan) { create(:activity_plan, activity: activity) }

  before do
    user.create_membership!(staff: staff, date: '2024-01-01', active: true, payed: true)
  end

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
    user.membership.destroy!
    user.reload_membership

    expect(user.membership).to be_nil

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
      start_date: '2024-01-02'
    )
    expect(sub1).to be_valid

    sub2 = build(
      :subscription,
      user: user,
      activity_plan: activity_plan,
      staff: staff,
      activity: activity,
      start_date: '2024-01-02'
    )
    expect(sub2).to be_valid
  end

  it 'should be valid with start_date but without end_date, end_date update automagically' do
    activity_plan_0 = build(:activity_plan, plan: :one_entrance, cost: 15, activity: activity)
    activity_plan_1 = build(:activity_plan, plan: :half_month, cost: 30, activity: activity)
    activity_plan_2 = build(:activity_plan, plan: :one_month, cost: 55, activity: activity)
    activity_plan_3 = build(:activity_plan, plan: :three_months, cost: 150, activity: activity)
    activity_plan_4 = build(:activity_plan, plan: :one_year, cost: 150, activity: activity)
    activity_plan_5 = build(:activity_plan, plan: :one_month_one_lesson, cost: 60, activity: activity)
    activity_plan_6 = build(:activity_plan, plan: :one_month_two_lessons, cost: 70, activity: activity)

    dates = [
      '2024-01-01',
      '2024-01-02',
      '2024-01-10',
      '2024-01-11',
      '2024-01-12',
      '2024-01-13',
      '2024-01-14',
      '2024-01-15',
      '2024-01-16',
      '2024-01-20',
      '2024-02-01',
      '2024-02-02',
      '2024-02-10',
      '2024-02-11',
      '2024-02-20',
      '2024-02-28', # End of February non-leap year
      '2024-02-29', # Leap year case
      '2024-03-01',
      '2024-03-31', # End of March
      '2024-04-01',
      '2024-04-30', # End of April
      '2024-05-01',
      '2024-06-30', # End of June
      '2024-07-01',
      '2024-08-31', # End of August
      '2024-09-01',
      '2024-10-31', # End of October
      '2024-11-01',
      '2024-12-31', # End of December
    ]

    # Test One Entrance
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_0,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date)
      expect(sub.end_date).to eq(date)
    end

    # Test Half Month
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_1,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      test_start_date = date.after?(date.at_beginning_of_month + 11.day) ? date.beginning_of_month + 14.day : date.to_date.beginning_of_month
      test_end_date = date.after?(date.at_beginning_of_month + 11.day) ? date.end_of_month : test_start_date + 14.day

      expect(sub.start_date).to eq(test_start_date)
      expect(sub.end_date).to eq(test_end_date)
    end

    # Test One Month
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_2,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date.beginning_of_month)
      expect(sub.end_date).to eq((date.beginning_of_month + 1.month) - 1.day)
    end

        # Test One Month One Lesson
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_5,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date.beginning_of_month)
      expect(sub.end_date).to eq((date.beginning_of_month + 1.month) - 1.day)
    end

    # Test One Month Two Lesson
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_6,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date.beginning_of_month)
      expect(sub.end_date).to eq((date.beginning_of_month + 1.month) - 1.day)
    end

    # Test Three Months
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_3,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date.beginning_of_month)
      expect(sub.end_date).to eq((date.beginning_of_month + 3.month) - 1.day)
    end

    # Test One Year
    dates.each do |date|
      sub = build(
        :subscription,
        user: user,
        activity_plan: activity_plan_4,
        staff: staff,
        activity: activity,
        start_date: date,
        end_date: nil
      )
      expect(sub).to be_valid
      date = date.to_date

      # puts "CURR_DATE #{date}"
      # puts "START_DATE #{sub.start_date}"
      # puts "END_DATE #{sub.end_date}"
      # puts ""

      expect(sub.start_date).to eq(date.beginning_of_month)
      expect(sub.end_date).to eq((date.beginning_of_year + 1.year) - 1.day)
    end
  end
end
