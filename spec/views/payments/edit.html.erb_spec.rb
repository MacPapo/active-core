# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'payments/edit', type: :view do
  let(:payment) do
    Payment.create!(
      amount: '9.99',
      type: 1,
      income: false,
      note: 'MyText',
      staff: nil
    )
  end

  before(:each) do
    assign(:payment, payment)
  end

  it 'renders the edit payment form' do
    render

    assert_select 'form[action=?][method=?]', payment_path(payment), 'post' do
      assert_select 'input[name=?]', 'payment[amount]'

      assert_select 'input[name=?]', 'payment[type]'

      assert_select 'input[name=?]', 'payment[income]'

      assert_select 'textarea[name=?]', 'payment[note]'

      assert_select 'input[name=?]', 'payment[staff_id]'
    end
  end
end
