require 'rails_helper'

RSpec.describe Course, type: :model do
  it 'shuold be valid with all attributes' do
    course = build(:course)
    expect(course).to be_valid
  end

  it 'should be invalid without name' do
    course = build(:course, name: nil)
    expect(course).to be_invalid
  end

  it 'should be invalid with duplicate name' do
    course_1 = create(:course, name: 'abc')
    course_2 = build(:course, name: 'abc')

    expect(course_2).to be_invalid
  end
end
