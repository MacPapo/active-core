require 'rails_helper'

RSpec.describe User, type: :model do

  it 'should be valid with all attributes' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'should be invalid without name' do
    user = build(:user, name: nil)
    expect(user).to be_invalid
  end

  it 'should be valid without email' do
    user = build(:user, email: nil)
    expect(user).to be_valid
  end

  it 'should be valid without phone' do
    user = build(:user, phone: nil)
    expect(user).to be_valid
  end

  it 'should be valid without med_cert_exp_date' do
    user = build(:user, med_cert_exp_date: nil)
    expect(user).to be_valid
  end

  it 'returns the full_name for a user' do
    user = build(:user, name: 'Pippo', surname: 'Baudo')

    expect(user.full_name).to eq 'Pippo Baudo'
  end

  it 'returns if the user is a minor' do
    [
      '2008-03-18',
      '2007-03-18',
    ].each do |date|
      user = build(:user, date_of_birth: date)
      expect(user).to be_minor
    end
  end
end
