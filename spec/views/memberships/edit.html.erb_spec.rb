require 'rails_helper'

RSpec.describe "memberships/edit", type: :view do
  let(:membership) {
    Membership.create!(
      active: false,
      subscription_type: nil,
      user: nil
    )
  }

  before(:each) do
    assign(:membership, membership)
  end

  it "renders the edit membership form" do
    render

    assert_select "form[action=?][method=?]", membership_path(membership), "post" do

      assert_select "input[name=?]", "membership[active]"

      assert_select "input[name=?]", "membership[subscription_type_id]"

      assert_select "input[name=?]", "membership[user_id]"
    end
  end
end
