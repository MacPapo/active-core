# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'payments/show', type: :view do
  before(:each) do
    assign(:payment, Payment.create!(
                       amount: '9.99',
                       type: 2,
                       income: false,
                       note: 'MyText',
                       staff: nil
                     ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
