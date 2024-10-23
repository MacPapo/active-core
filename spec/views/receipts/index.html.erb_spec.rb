# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'receipts/index', type: :view do
  before(:each) do
    assign(:receipts, [
             Receipt.create!(
               payment: nil,
               amount: '9.99',
               staff: nil
             ),
             Receipt.create!(
               payment: nil,
               amount: '9.99',
               staff: nil
             )
           ])
  end

  it 'renders a list of receipts' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('9.99'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
