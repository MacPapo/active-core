require 'rails_helper'

RSpec.describe "memberships/show", type: :view do
  before(:each) do
    assign(:membership, Membership.create!(
      active: false,
      subscription_type: nil,
      user: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
