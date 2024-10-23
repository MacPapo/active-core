# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'payments/new', type: :view do
  before(:each) do
    assign(:payment, Payment.new(
                       amount: '9.99',
                       type: 1,
                       income: false,
                       note: 'MyText',
                       staff: nil
                     ))
  end

  it 'renders new payment form' do
    render

    assert_select 'form[action=?][method=?]', payments_path, 'post' do
      assert_select 'input[name=?]', 'payment[amount]'

      assert_select 'input[name=?]', 'payment[type]'

      assert_select 'input[name=?]', 'payment[income]'

      assert_select 'textarea[name=?]', 'payment[note]'

      assert_select 'input[name=?]', 'payment[staff_id]'
    end
  end
end
