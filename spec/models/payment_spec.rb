require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { create(:user) }
  let(:staff) { create(:staff, user: user) }
  let(:subscription_type) { create(:subscription_type) }
  let(:subscription) { create(:subscription, user: user, staff: staff, subscription_type: subscription_type) }


  context 'validations' do
    it 'is valid with valid attributes' do
      payment = build(:payment, staff: staff, subscription: subscription)
      expect(payment).to be_valid
    end

    it 'is invalid without amount' do
      payment = build(:payment, amount: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end

    it 'is invalid without date' do
      payment = build(:payment, date: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end

    it 'is invalid without payment_method' do
      payment = build(:payment, payment_method: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end

    it 'is invalid without payment_type' do
      payment = build(:payment, payment_type: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end

    it 'is invalid without entry_type' do
      payment = build(:payment, entry_type: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end

    it 'is invalid without payed status' do
      payment = build(:payment, payed: nil, staff: staff, subscription: subscription)
      expect(payment).not_to be_valid
    end
  end
end
