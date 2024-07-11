require 'rails_helper'

RSpec.describe Activity, type: :model do
  it 'shuold be valid with all attributes' do
    activity = build(:activity)
    expect(activity).to be_valid
  end

  it 'should be invalid without name' do
    activity = build(:activity, name: nil)
    expect(activity).not_to be_valid
  end

  it 'should be invalid with duplicate name' do
    activity_1 = create(:activity, name: 'abc')
    activity_2 = build(:activity, name: 'abc')

    expect(activity_2).not_to be_valid
  end
end
