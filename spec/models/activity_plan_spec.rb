require 'rails_helper'

RSpec.describe ActivityPlan, type: :model do
  let(:activity) { create(:activity) }
  let(:act_1) { create(:activity_plan, plan: :half_month, cost: 30, activity: activity) }
  let(:act_2) { create(:activity_plan, activity: activity) }
  let(:act_3) { create(:activity_plan, plan: :three_months,  cost: 150, activity: activity) }

  it 'should be valid with all the attributes' do
    expect(act_2).to be_valid
    expect(act_1).to be_valid
    expect(act_3).to be_valid
  end

  it 'should be invalid without activity attribute' do
    act = build(:activity_plan, activity: nil)
    expect(act).not_to be_valid
  end

  it 'should be invalid without plan attribute' do
    act = build(:activity_plan, activity: activity, plan: nil)
    expect(act).not_to be_valid
  end

  it 'should be invalid without cost attribute' do
    act = build(:activity_plan, activity: activity, cost: nil)
    expect(act).not_to be_valid
  end

  it 'should be valid without affiliated_cost attribute' do
    act = build(:activity_plan, activity: activity, affiliated_cost: nil)
    expect(act).to be_valid
  end
end
