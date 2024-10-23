# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'receipts/edit', type: :view do
  let(:receipt) do
    Receipt.create!(
      payment: nil,
      amount: '9.99',
      staff: nil
    )
  end

  before(:each) do
    assign(:receipt, receipt)
  end

  it 'renders the edit receipt form' do
    render

    assert_select 'form[action=?][method=?]', receipt_path(receipt), 'post' do
      assert_select 'input[name=?]', 'receipt[payment_id]'

      assert_select 'input[name=?]', 'receipt[amount]'

      assert_select 'input[name=?]', 'receipt[staff_id]'
    end
  end
end
