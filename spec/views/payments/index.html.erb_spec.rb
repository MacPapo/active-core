# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'payments/index', type: :view do
  before(:each) do
    assign(:payments, [
             Payment.create!(
               amount: '9.99',
               type: 2,
               income: false,
               note: 'MyText',
               staff: nil
             ),
             Payment.create!(
               amount: '9.99',
               type: 2,
               income: false,
               note: 'MyText',
               staff: nil
             )
           ])
  end

  it 'renders a list of payments' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new('9.99'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('MyText'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
