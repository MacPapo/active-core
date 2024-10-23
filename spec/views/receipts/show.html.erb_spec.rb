# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'receipts/show', type: :view do
  before(:each) do
    assign(:receipt, Receipt.create!(
                       payment: nil,
                       amount: '9.99',
                       staff: nil
                     ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(//)
  end
end
