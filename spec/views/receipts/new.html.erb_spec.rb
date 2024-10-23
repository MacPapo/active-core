# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'receipts/new', type: :view do
  before(:each) do
    assign(:receipt, Receipt.new(
                       payment: nil,
                       amount: '9.99',
                       staff: nil
                     ))
  end

  it 'renders new receipt form' do
    render

    assert_select 'form[action=?][method=?]', receipts_path, 'post' do
      assert_select 'input[name=?]', 'receipt[payment_id]'

      assert_select 'input[name=?]', 'receipt[amount]'

      assert_select 'input[name=?]', 'receipt[staff_id]'
    end
  end
end
