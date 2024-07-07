require 'rails_helper'

RSpec.describe Staff, type: :model do
  let(:user) { create(:user) }

  it 'should be invalid without user reference' do
    staff = build(:staff)
    expect(staff).to be_invalid
  end

  it 'should be valid with all attributes' do
    staff = build(:staff, user: user)
    expect(staff).to be_valid
  end

  it 'should be invalid without email' do
    staff = build(:staff, user: user, email: nil)
    expect(staff).to be_invalid
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
      staff = build(:staff, user: user, email: mail)
      expect(staff).to be_invalid
    end
  end

  it 'should be invalid without password' do
    staff = build(:staff, user: user, password: nil)
    expect(staff).to be_invalid
  end

  it 'should be invalid with empty password' do
    staff = build(:staff, user: user, password: '')
    expect(staff).to be_invalid
  end

  it 'should be invalid without role' do
    staff = build(:staff, user: user, role: nil)
    expect(staff).to be_invalid
  end

  it 'should be valid with well formed role' do
    [
      :admin,
      :collaboratore,
      :volontario
    ].each do |role|
      staff = build(:staff, user: user, role: role)
      expect(staff).to be_valid
    end
  end

  it 'should print the full name' do
    user = build(:user, name: 'Pippo', surname: 'Baudo')
    staff = build(:staff, user: user)
    expect(staff.full_name).to eq 'Pippo Baudo'
  end
end
