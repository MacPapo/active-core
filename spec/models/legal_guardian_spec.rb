require 'rails_helper'

RSpec.describe LegalGuardian, type: :model do
  it 'should be valid with all attributes' do
    legal_guardian = build(:legal_guardian)
    expect(legal_guardian).to be_valid
  end

  it 'should be invalid without name' do
    legal_guardian = build(:legal_guardian, name: nil)
    expect(legal_guardian).to be_invalid
  end

  it 'should be invalid without surname' do
    legal_guardian = build(:legal_guardian, surname: nil)
    expect(legal_guardian).to be_invalid
  end

  it 'should be invalid without email' do
    legal_guardian = build(:legal_guardian, email: nil)
    expect(legal_guardian).to be_invalid
  end

  it 'should be invalid with malformed email' do
    [
      'pippobaudoballerino.com',
      'pippobaudoballerino@',
      '@pippobaudoballerino.it',
      'pippobaudo ballerino.it',
      'pippobaudo ballerino@.it',
      'pippobaudo ballerino@gmail.it',
      '1234@.it',
    ].each do |mail|
      user = build(:legal_guardian, email: mail)
      expect(user).to be_invalid
    end
  end

  it 'should be invalid without phone' do
    legal_guardian = build(:legal_guardian, phone: nil)
    expect(legal_guardian).to be_invalid
  end

  it 'should be invalid with malformed phone' do
    [
      '+29 341 5555 932',
      '34155559',
      '+39 341 5555 9',
      '+39 341 5555 9322',
    ].each do |tell|
      legal_guardian = build(:legal_guardian, phone: tell)
      expect(legal_guardian).to be_invalid
    end
  end

  it 'should normalizes the phone number before saving' do
    user = create(:user, phone: '+39 341 5555 932')
    expect(user.phone).to eq('+393415555932')
  end

  it 'should be invalid if minor' do
    [
      '2008-03-18',
      '2007-03-18',
    ].each do |date|
      legal_guardian = build(:legal_guardian, date_of_birth: date)
      expect(legal_guardian).to be_invalid
    end
  end

  it 'should be valid if adult' do
    [
      '1990-03-18',
      '1980-03-18',
    ].each do |date|
      legal_guardian = build(:legal_guardian, date_of_birth: date)
      expect(legal_guardian).to be_valid
    end
  end

  it 'returns the full_name for a legal_guardian' do
    legal_guardian = build(:legal_guardian, name: 'Pippo', surname: 'Baudo')

    expect(legal_guardian.full_name).to eq 'Pippo Baudo'
  end
end
