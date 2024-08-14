require 'rails_helper'

RSpec.describe User, type: :model do
  let(:legal_guardian) { create(:legal_guardian) }

  it 'should be valid with all attributes' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'should be invalid without name' do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
  end

  it 'should be invalid without surname' do
    user = build(:user, surname: nil)
    expect(user).not_to be_valid
  end

  it 'should be valid without email' do
    user = build(:user, email: nil)
    expect(user).to be_valid
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
      user = build(:user, email: mail)
      expect(user).not_to be_valid
    end
  end

  it 'should be valid without phone' do
    user = build(:user, phone: nil)
    expect(user).to be_valid
  end

  it 'should be invalid with malformed phone' do
    [
      '+29 341 5555 932',
      '34155559',
      '+39 341 5555 9',
      '+39 341 5555 9322',
    ].each do |tell|
      legal_guardian = build(:legal_guardian, phone: tell)
      expect(legal_guardian).not_to be_valid
    end
  end

  it 'normalizes the phone number before saving' do
    user = create(:user, phone: '+39 341 5555 932')
    expect(user.phone).to eq('+393415555932')
  end

  it 'should be valid without med_cert_issue_date' do
    user = build(:user, med_cert_issue_date: nil)
    expect(user).to be_valid
  end

  it 'should be invalid with med_cert_issue_date in the future' do
    [
      '2028-01-01',
      '2026-01-01',
      '2025-01-01',
    ].each do |issue_date|
      user = build(:user, med_cert_issue_date: issue_date)

      expect(user).not_to be_valid
    end
  end

  it 'should be invalid with med_cert_issue_date in the past' do
    [
      '2023-01-01',
      '2024-01-01',
      '2024-02-01',
      '2024-03-01',
    ].each do |issue_date|
      user = build(:user, med_cert_issue_date: issue_date)

      expect(user).to be_valid
    end
  end

  it 'should returns that med_cert is valid' do
    [
      '2024-01-01',
      '2024-02-01',
      '2024-03-01',
      '2024-04-01',
    ].each do |issue_date|
      user = build(:user, med_cert_issue_date: issue_date)

      expect(user).to be_med_cert_valid
    end
  end

  it 'should returns that med_cert is invalid' do
    [
      '2020-01-01',
      '2021-02-01',
      '2022-03-01',
    ].each do |issue_date|
      user = build(:user, med_cert_issue_date: issue_date)

      expect(user).not_to be_med_cert_valid
    end
  end

  it 'should returns the full_name for a user' do
    user = build(:user, name: 'Pippo', surname: 'Baudo')

    expect(user.full_name).to eq 'Pippo Baudo'
  end

  it 'should returns if the user is a minor' do
    [
      '2008-03-18',
      '2007-03-18',
    ].each do |date|
      user = build(:user, birth_day: date)
      expect(user).to be_minor
    end
  end

  it 'should returns if the user is not minor' do
    [
      '1990-03-18',
      '1980-03-18',
    ].each do |date|
      user = build(:user, birth_day: date)
      expect(user).not_to be_minor
    end
  end

  it 'should be invalid if minor without legal_guardian' do
    [
      '2007-01-01',
      '2008-01-01',
      '2009-01-01',
    ].each do |birth|
      user = build(:user, birth_day: birth, legal_guardian: nil)
      expect(user).not_to be_valid
    end
  end

  it 'should be valid if adult without legal_guardian' do
    [
      '1990-01-01',
      '1980-01-01',
      '1970-01-01',
    ].each do |birth|
      user = build(:user, birth_day: birth, legal_guardian: nil)
      expect(user).to be_valid
    end
  end

  it 'should be valid if minor with legal_guardian' do
    [
      '2007-01-01',
      '2008-01-01',
      '2009-01-01',
    ].each do |birth|
      user = build(:user, birth_day: birth, legal_guardian: legal_guardian)
      expect(user).to be_valid
    end
  end
end
